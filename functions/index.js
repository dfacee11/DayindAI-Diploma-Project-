const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const vision = require("@google-cloud/vision");
const axios = require("axios");
const FormData = require("form-data");

const DEEPSEEK_API_KEY = defineSecret("DEEPSEEK_API_KEY");
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");
const ELEVENLABS_API_KEY = defineSecret("ELEVENLABS_API_KEY");
const ANTHROPIC_KEY = defineSecret("ANTHROPIC_KEY");

const client = new vision.ImageAnnotatorClient();

exports.extractTextFromImage = onCall(async (request) => {
  try {
    const base64 = request.data?.imageBase64;
    if (!base64) throw new HttpsError("invalid-argument", "base64 image is required");
    const cleanedBase64 = base64.includes("base64,") ? base64.split("base64,")[1] : base64;
    const [result] = await client.textDetection({ image: { content: cleanedBase64 } });
    const text = result.fullTextAnnotation?.text || "";
    return { text };
  } catch (e) {
    console.log("OCR error:", e);
    throw new HttpsError("internal", e.message || "OCR failed");
  }
});

exports.analyzeResume = onCall(
  { secrets: [OPENAI_API_KEY] },
  async (request) => {
    try {
      const text = request.data?.text;
      const profession = request.data?.profession;
      if (!text || text.trim().length < 30) throw new HttpsError("invalid-argument", "Resume text is too short");
      if (!profession) throw new HttpsError("invalid-argument", "Profession is required");
      const apiKey = OPENAI_API_KEY.value();
      const prompt = `You are a senior HR recruiter and resume expert.\nAnalyze this resume for the role: ${profession}\n\nReturn ONLY valid JSON, no markdown:\n{\n  "score": <integer 1-10>,\n  "verdict": "Strong" | "Average" | "Weak",\n  "experienceLevel": "Intern" | "Junior" | "Middle" | "Senior",\n  "atsScore": <integer 0-100>,\n  "strengths": ["<strength 1>", "<strength 2>", "<strength 3>"],\n  "weaknesses": ["<weakness 1>", "<weakness 2>", "<weakness 3>"],\n  "recommendations": ["<rec 1>", "<rec 2>", "<rec 3>"],\n  "keySkillsFound": ["<skill 1>", "<skill 2>", "<skill 3>", "<skill 4>"],\n  "missingSkills": ["<missing 1>", "<missing 2>", "<missing 3>"],\n  "levelMatch": {\n    "Junior": <integer 0-100>,\n    "Middle": <integer 0-100>,\n    "Senior": <integer 0-100>\n  }\n}\n\nResume:\n${text}`;
      const response = await axios.post("https://api.openai.com/v1/chat/completions", { model: "gpt-4o-mini", messages: [{ role: "system", content: "Strict JSON generator. Return only valid JSON, no markdown." }, { role: "user", content: prompt }], temperature: 0.2, max_tokens: 800 }, { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } });
      const content = response.data?.choices?.[0]?.message?.content;
      if (!content) throw new HttpsError("internal", "Empty response");
      const cleaned = content.replace(/```json/g, "").replace(/```/g, "").trim();
      return JSON.parse(cleaned);
    } catch (e) {
      console.log("Analyze error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Analyze failed");
    }
  }
);

exports.matchResume = onCall(
  { secrets: [OPENAI_API_KEY] },
  async (request) => {
    try {
      const resumeText = request.data?.resumeText;
      const jobText = request.data?.jobText;
      if (!resumeText || resumeText.trim().length < 30) throw new HttpsError("invalid-argument", "Resume text is too short");
      if (!jobText || jobText.trim().length < 30) throw new HttpsError("invalid-argument", "Job text is too short");
      const apiKey = OPENAI_API_KEY.value();
      const prompt = `You are a professional ATS system and recruiter.\nCompare the resume with the job description.\n\nReturn ONLY valid JSON, no markdown:\n{\n  "score": <integer 0-100>,\n  "verdict": "Strong Match" | "Good Match" | "Weak Match",\n  "atsScore": <integer 0-100>,\n  "experienceMatch": "Exceeds" | "Meets" | "Below",\n  "matched": ["<keyword 1>", "<keyword 2>", "<keyword 3>"],\n  "missing": ["<keyword 1>", "<keyword 2>", "<keyword 3>"],\n  "topStrengths": ["<strength 1>", "<strength 2>"],\n  "criticalGaps": ["<gap 1>", "<gap 2>"],\n  "tips": ["<tip 1>", "<tip 2>", "<tip 3>"]\n}\n\nRESUME: ${resumeText}\nJOB DESCRIPTION: ${jobText}`;
      const response = await axios.post("https://api.openai.com/v1/chat/completions", { model: "gpt-4o-mini", messages: [{ role: "system", content: "Strict JSON generator. Return only valid JSON, no markdown." }, { role: "user", content: prompt }], temperature: 0.2, max_tokens: 700 }, { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } });
      const content = response.data?.choices?.[0]?.message?.content;
      if (!content) throw new HttpsError("internal", "Empty response");
      const cleaned = content.replace(/```json/g, "").replace(/```/g, "").trim();
      const parsed = JSON.parse(cleaned);
      if (typeof parsed.score === "number") parsed.score = Math.round(parsed.score);
      if (typeof parsed.atsScore === "number") parsed.atsScore = Math.round(parsed.atsScore);
      return parsed;
    } catch (e) {
      console.log("Matching error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Matching failed");
    }
  }
);

exports.transcribeAudio = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 60, region: "europe-west1" },
  async (request) => {
    try {
      // ─── WARMUP ───
      if (request.data?.warmup) return { transcript: '' };

      const audioBase64 = request.data?.audioBase64;
      const mimeType = request.data?.mimeType || "audio/m4a";
      const language = request.data?.language || "en";
      if (!audioBase64) throw new HttpsError("invalid-argument", "audioBase64 is required");
      const apiKey = OPENAI_API_KEY.value();
      const buffer = Buffer.from(audioBase64, "base64");
      const form = new FormData();
      form.append("file", buffer, { filename: "audio.m4a", contentType: mimeType });
      form.append("model", "whisper-1");
      form.append("language", language);
      const response = await axios.post("https://api.openai.com/v1/audio/transcriptions", form, { headers: { Authorization: `Bearer ${apiKey}`, ...form.getHeaders() } });
      return { transcript: response.data?.text || "" };
    } catch (e) {
      console.log("Whisper error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Transcription failed");
    }
  }
);

exports.interviewChat = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 60, region: "europe-west1" },
  async (request) => {
    try {
      
      if (request.data?.warmup) return { reply: 'ok' };

      const messages            = request.data?.messages || [];
      const jobRole             = request.data?.jobRole || "Software Engineer";
      const interviewTypeHint   = request.data?.interviewTypeHint || "";
      const languageInstruction = request.data?.languageInstruction || "Conduct the entire interview in English.";
      const levelHint           = request.data?.levelHint || "";
      const questionIndex       = request.data?.questionIndex || 0;
      const totalQuestions      = request.data?.totalQuestions || 7;
      const jobDescription      = request.data?.jobDescription || null;
      const apiKey = OPENAI_API_KEY.value();
      const isLastQuestion = questionIndex >= totalQuestions - 1;

      let systemPrompt = `You are a professional interviewer conducting a job interview.

Role: ${jobRole}
LEVEL: ${levelHint}
LANGUAGE: ${languageInstruction}
FOCUS: ${interviewTypeHint}

Rules:
- Ask ONE question at a time
- Adjust difficulty strictly to the candidate's level
- Keep responses concise (2-4 sentences max)
- Be professional but friendly
- This is question ${questionIndex + 1} of ${totalQuestions}
${isLastQuestion
  ? `- This is the LAST question. After the candidate answers, give a brief encouraging closing statement.`
  : `- After the candidate answers, acknowledge briefly and ask the next relevant question.`
}
- Do NOT number your questions out loud`;

      if (jobDescription) {
        systemPrompt += `\n\nJOB DESCRIPTION PROVIDED BY CANDIDATE:\n${jobDescription}\n\nBase your interview questions specifically on this job posting. Focus on the required skills, technologies, and responsibilities mentioned in the job description.`;
      }

      const response = await axios.post("https://api.openai.com/v1/chat/completions", { model: "gpt-4o", messages: [{ role: "system", content: systemPrompt }, ...messages], temperature: 0.7, max_tokens: 250 }, { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } });
      return { reply: response.data?.choices?.[0]?.message?.content || "" };
    } catch (e) {
      console.log("Interview chat error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Interview failed");
    }
  }
);

exports.interviewFeedback = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 90, region: "europe-west1" },
  async (request) => {
    try {
      const messages            = request.data?.messages || [];
      const jobRole             = request.data?.jobRole || "Software Engineer";
      const languageInstruction = request.data?.languageInstruction || "Respond in English.";
      const level               = request.data?.level || "Junior";
      const jobDescription      = request.data?.jobDescription || null;
      const apiKey = OPENAI_API_KEY.value();

      const pairs = [];
      for (let i = 0; i < messages.length - 1; i++) {
        if (messages[i].role === "assistant" && messages[i + 1].role === "user") {
          pairs.push({ question: messages[i].content, answer: messages[i + 1].content });
        }
      }

      const transcript = messages.map((m) => `${m.role === "user" ? "Candidate" : "Interviewer"}: ${m.content}`).join("\n");
      const jobContext = jobDescription ? `\nJOB DESCRIPTION:\n${jobDescription}\nEvaluate answers specifically against requirements in this job posting.\n` : '';

      const prompt = `
LANGUAGE INSTRUCTION: ${languageInstruction}

You are a senior HR expert analyzing a ${level} job interview for: ${jobRole}
${jobContext}
Evaluate answers based on ${level} expectations.

Interview transcript:
${transcript}

Return ONLY valid JSON (keys in English, text values in interview language):
{
  "overallScore": <integer 0-100>,
  "verdict": "Hire" | "Maybe" | "No Hire",
  "summary": "<2-3 sentence overall assessment>",
  "strengths": ["<strength 1>", "<strength 2>", "<strength 3>"],
  "improvements": ["<area 1>", "<area 2>", "<area 3>"],
  "tips": ["<concrete tip with example: Instead of X, say Y>", "<tip 2>", "<tip 3>"],
  "categories": {
    "Communication": <integer 0-100>,
    "Knowledge": <integer 0-100>,
    "Confidence": <integer 0-100>,
    "Structure": <integer 0-100>
  },
  "answerAnalysis": [
    ${pairs.map((p) => `{
      "question": ${JSON.stringify(p.question.slice(0, 120))},
      "score": <integer 0-100>,
      "feedback": "<2-3 sentence specific feedback>"
    }`).join(",\n    ")}
  ]
}`;

      const response = await axios.post("https://api.openai.com/v1/chat/completions", { model: "gpt-4o", messages: [{ role: "system", content: "Strict JSON generator. Return only valid JSON, no markdown." }, { role: "user", content: prompt }], temperature: 0.3, max_tokens: 1800 }, { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } });
      const content = response.data?.choices?.[0]?.message?.content || "";
      const cleaned = content.replace(/```json/g, "").replace(/```/g, "").trim();
      const parsed = JSON.parse(cleaned);
      if (typeof parsed.overallScore === "number") parsed.overallScore = Math.round(parsed.overallScore);
      return parsed;
    } catch (e) {
      console.log("Feedback error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Feedback failed");
    }
  }
);

exports.textToSpeech = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 60, region: "europe-west1" },
  async (request) => {
    try {
      // ─── WARMUP ───
      if (request.data?.warmup) return { audioBase64: '' };

      const text = request.data?.text;
      if (!text) throw new HttpsError("invalid-argument", "text is required");
      const apiKey = OPENAI_API_KEY.value();
      console.log("TTS OpenAI request, textLength:", text.length);
      const response = await axios.post("https://api.openai.com/v1/audio/speech", { model: "tts-1", input: text, voice: "nova", response_format: "mp3", speed: 1.0 }, { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" }, responseType: "arraybuffer" });
      const audioBase64 = Buffer.from(response.data).toString("base64");
      console.log("TTS success, length:", audioBase64.length);
      return { audioBase64 };
    } catch (e) {
      const errBody = e?.response?.data ? Buffer.from(e.response.data).toString("utf8") : e.message;
      console.log("TTS error:", e?.response?.status, errBody);
      throw new HttpsError("internal", errBody || "TTS failed");
    }
  }
);

exports.visaInterviewFeedback = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 90, region: "europe-west1" },
  async (request) => {
    try {
      const messages = request.data?.messages || [];
      const city     = request.data?.city || "Астана";
      const apiKey = OPENAI_API_KEY.value();

      const pairs = [];
      for (let i = 0; i < messages.length - 1; i++) {
        if (messages[i].role === "assistant" && messages[i + 1].role === "user") {
          pairs.push({ question: messages[i].content, answer: messages[i + 1].content });
        }
      }

      const transcript = messages.map((m) => `${m.role === "user" ? "Candidate" : "Consul"}: ${m.content}`).join("\n");

      const prompt = `
You are a US consular officer making a final visa decision for a Work & Travel (J-1) applicant from ${city}, Kazakhstan.

HOW REAL VISA INTERVIEWS WORK:
- Approval rate for Work & Travel from Kazakhstan is ~85-90%
- English level does NOT matter — only intent and ties to home country matter
- Short answers are fine. Nervousness is fine. Accent is fine.
- Decision is binary: APPROVED or REJECTED — no "maybe"

REJECT only if ONE OR MORE of these red flags exist:
1. Candidate hinted at wanting to stay in the US / find work / immigrate
2. Candidate has NO ties to home country (no family, no university, no job waiting)
3. Candidate couldn't explain basic details about their employer or program
4. Candidate contradicted themselves on key facts
5. Candidate was completely unable to communicate

If none of these red flags → APPROVE. Be realistic and generous.

Interview transcript:
${transcript}

Return ONLY valid JSON (keys in English, text values in Russian):
{
  "verdict": "Одобрено" | "Отказано",
  "approvalScore": <integer 0-100>,
  "summary": "<2-3 предложения — итоговое решение и почему>",
  "redFlags": ["<красный флаг если есть, или пустой массив []>"],
  "strengths": ["<что кандидат сделал хорошо 1>", "<хорошо 2>"],
  "tips": ["<совет как улучшить ответы на следующий раз>", "<совет 2>"],
  "answerAnalysis": [
    ${pairs.map((p) => `{
      "question": ${JSON.stringify(p.question.slice(0, 120))},
      "verdict": "OK" | "Слабый ответ" | "Красный флаг",
      "feedback": "<1-2 предложения. Не критикуй английский. Только содержание>"
    }`).join(",\n    ")}
  ]
}

If verdict is "Одобрено": redFlags = [], approvalScore >= 70
If verdict is "Отказано": redFlags must list specific reasons, approvalScore < 60
`;

      const response = await axios.post("https://api.openai.com/v1/chat/completions", { model: "gpt-4o", messages: [{ role: "system", content: "Strict JSON generator. Return only valid JSON, no markdown." }, { role: "user", content: prompt }], temperature: 0.3, max_tokens: 2000 }, { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } });
      const content = response.data?.choices?.[0]?.message?.content || "";
      const cleaned = content.replace(/```json/g, "").replace(/```/g, "").trim();
      const parsed = JSON.parse(cleaned);
      if (typeof parsed.approvalScore === "number") parsed.approvalScore = Math.round(parsed.approvalScore);
      return parsed;
    } catch (e) {
      console.log("Visa feedback error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Visa feedback failed");
    }
  }
);


// Добавь в начало файла рядом с другими defineSecret:
// const ANTHROPIC_KEY = defineSecret("ANTHROPIC_KEY");

exports.improveResume = onCall(
  { secrets: [ANTHROPIC_KEY], timeoutSeconds: 60, region: "europe-west1" },
  async (request) => {
    try {
      const {
        fullName,
        jobTitle,
        email,
        phone,
        location,
        summary,
        experience,   // [{ company, role, period, description }]
        education,    // [{ institution, degree, period }]
        skills,       // string — через запятую
        languages,    // string — например "Казахский, Русский, Английский"
        language,     // язык вывода: "ru" | "kk" | "en"
      } = request.data || {};

      if (!fullName || !jobTitle) {
        throw new HttpsError("invalid-argument", "fullName and jobTitle are required");
      }

      const apiKey = ANTHROPIC_KEY.value();

      const langInstruction = language === "kk"
        ? "Respond entirely in Kazakh language."
        : language === "ru"
        ? "Respond entirely in Russian language."
        : "Respond entirely in English language.";

      const expText = (experience && experience.length > 0)
        ? experience.map(e => `Company: ${e.company}, Role: ${e.role}, Period: ${e.period}, Description: ${e.description}`).join('\n')
        : 'No experience provided';

      const eduText = (education && education.length > 0)
        ? education.map(e => `Institution: ${e.institution}, Degree: ${e.degree}, Period: ${e.period}`).join('\n')
        : 'No education provided';

      const prompt = `${langInstruction}

You are a professional resume writer. Improve this resume data to sound professional and ATS-friendly.

STRICT RULES:
- Do NOT invent facts, keep all real data
- Make descriptions result-oriented with action verbs
- Summary: exactly 2-3 sentences
- Each job: 2-3 bullet points starting with action verbs
- If no experience provided, return experience as empty array []
- If no education provided, return education as empty array []
- Return ONLY raw JSON, absolutely no markdown, no backticks, no explanation

INPUT:
Name: ${fullName}
Title: ${jobTitle}
Email: ${email || ''}
Phone: ${phone || ''}
Location: ${location || ''}
Summary: ${summary || ''}
Skills: ${skills || ''}
Languages: ${languages || ''}
Experience:
${expText}
Education:
${eduText}

OUTPUT FORMAT (raw JSON only):
{"fullName":"${fullName}","jobTitle":"improved title","email":"${email || ''}","phone":"${phone || ''}","location":"${location || ''}","summary":"improved summary","experience":[{"company":"same","role":"same","period":"same","bullets":["bullet 1","bullet 2"]}],"education":[{"institution":"same","degree":"same","period":"same"}],"skills":"improved skills","languages":"${languages || ''}"}`;

      const response = await axios.post(
        "https://api.anthropic.com/v1/messages",
        {
          model: "claude-haiku-4-5",
          max_tokens: 1500,
          messages: [{ role: "user", content: prompt }],
        },
        {
          headers: {
            "x-api-key": apiKey,
            "anthropic-version": "2023-06-01",
            "Content-Type": "application/json",
          },
        }
      );

      const content = response.data?.content?.[0]?.text || "";
      // Aggressive cleaning — remove any markdown, backticks, leading text
      let cleaned = content
        .replace(/```json/gi, '')
        .replace(/```/g, '')
        .trim();
      // Find first { and last } to extract pure JSON
      const start = cleaned.indexOf('{');
      const end = cleaned.lastIndexOf('}');
      if (start === -1 || end === -1) throw new Error('No JSON found in response');
      cleaned = cleaned.substring(start, end + 1);
      return JSON.parse(cleaned);
    } catch (e) {
      console.log("improveResume error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Resume improvement failed");
    }
  }
);