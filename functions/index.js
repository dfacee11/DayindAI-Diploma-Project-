const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const vision = require("@google-cloud/vision");
const axios = require("axios");
const FormData = require("form-data");

const DEEPSEEK_API_KEY = defineSecret("DEEPSEEK_API_KEY");
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");
const ELEVENLABS_API_KEY = defineSecret("ELEVENLABS_API_KEY");

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



exports.extractTextFromPdf = onCall({ invoker: "public" }, async (request) => {
  try {
    const base64 = request.data?.pdfBase64;
    if (!base64) throw new HttpsError("invalid-argument", "base64 pdf is required");

    const cleanedBase64 = base64.includes("base64,") ? base64.split("base64,")[1] : base64;
    const buffer = Buffer.from(cleanedBase64, "base64");

  
    const pdfParse = require("pdf-parse/lib/pdf-parse.js");
    const data = await pdfParse(buffer);
    const text = data.text || "";

    if (!text.trim()) throw new HttpsError("internal", "PDF has no readable text");

    return { text };
  } catch (e) {
    console.log("PDF parse error:", e);
    throw new HttpsError("internal", e.message || "PDF parsing failed");
  }
});


exports.analyzeResumeDeepseek = onCall(
  { secrets: [DEEPSEEK_API_KEY] },
  async (request) => {
    try {
      const text = request.data?.text;
      const profession = request.data?.profession;

      if (!text || text.trim().length < 30) throw new HttpsError("invalid-argument", "Resume text is too short");
      if (!profession) throw new HttpsError("invalid-argument", "Profession is required");

      const apiKey = DEEPSEEK_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing DEEPSEEK_API_KEY secret");

      const prompt = `
You are a professional HR recruiter.
Analyze this resume for the profession: ${profession}
Return ONLY valid JSON in this exact format:
{
  "score": 0-10,
  "strengths": ["..."],
  "weaknesses": ["..."],
  "recommendations": ["..."],
  "levelMatch": {
    "Junior": 0-100,
    "Middle": 0-100,
    "Senior": 0-100
  }
}
Resume text:
${text}
`;

      const response = await axios.post(
        "https://api.deepseek.com/chat/completions",
        {
          model: "deepseek-chat",
          messages: [
            { role: "system", content: "You are a strict JSON generator. Return only valid JSON." },
            { role: "user", content: prompt },
          ],
          temperature: 0.3,
        },
        { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } }
      );

      const content = response.data?.choices?.[0]?.message?.content;
      if (!content) throw new HttpsError("internal", "Empty DeepSeek response");

      const cleaned = content.replace(/```json/g, "").replace(/```/g, "").trim();
      try {
        return JSON.parse(cleaned);
      } catch {
        throw new HttpsError("internal", "DeepSeek returned invalid JSON");
      }
    } catch (e) {
      console.log("Analyze error:", e);
      throw new HttpsError("internal", e.message || "Analyze failed");
    }
  }
);


exports.matchResumeDeepseek = onCall(
  { secrets: [DEEPSEEK_API_KEY] },
  async (request) => {
    try {
      const resumeText = request.data?.resumeText;
      const jobText = request.data?.jobText;

      if (!resumeText || resumeText.trim().length < 30) throw new HttpsError("invalid-argument", "Resume text is too short");
      if (!jobText || jobText.trim().length < 30) throw new HttpsError("invalid-argument", "Job text is too short");

      const apiKey = DEEPSEEK_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing DEEPSEEK_API_KEY secret");

      const prompt = `
You are a professional ATS and recruiter.
Compare the RESUME with the JOB DESCRIPTION.
Return ONLY valid JSON:
{
  "score": 0-100,
  "matched": ["keyword1", "keyword2"],
  "missing": ["keyword1", "keyword2"],
  "tips": ["tip1", "tip2", "tip3"]
}
RESUME: ${resumeText}
JOB DESCRIPTION: ${jobText}
`;

      const response = await axios.post(
        "https://api.deepseek.com/chat/completions",
        {
          model: "deepseek-chat",
          messages: [
            { role: "system", content: "You are a strict JSON generator. Return only valid JSON." },
            { role: "user", content: prompt },
          ],
          temperature: 0.2,
        },
        { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } }
      );

      const content = response.data?.choices?.[0]?.message?.content;
      if (!content) throw new HttpsError("internal", "Empty DeepSeek response");

      const cleaned = content.replace(/```json/g, "").replace(/```/g, "").trim();
      let parsed;
      try {
        parsed = JSON.parse(cleaned);
      } catch {
        throw new HttpsError("internal", "DeepSeek returned invalid JSON");
      }

      if (typeof parsed.score === "number") parsed.score = Math.round(parsed.score);
      return parsed;
    } catch (e) {
      console.log("Matching error:", e);
      throw new HttpsError("internal", e.message || "Matching failed");
    }
  }
);


exports.transcribeAudio = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 60,region: "europe-west1" },
  async (request) => {
    try {
      const audioBase64 = request.data?.audioBase64;
      const mimeType = request.data?.mimeType || "audio/m4a";
      const language = request.data?.language || "en"; 

      if (!audioBase64) throw new HttpsError("invalid-argument", "audioBase64 is required");

      const apiKey = OPENAI_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing OPENAI_API_KEY secret");

      const buffer = Buffer.from(audioBase64, "base64");
      const form = new FormData();
      form.append("file", buffer, { filename: "audio.m4a", contentType: mimeType });
      form.append("model", "whisper-1");
      form.append("language", language); 

      const response = await axios.post(
        "https://api.openai.com/v1/audio/transcriptions",
        form,
        { headers: { Authorization: `Bearer ${apiKey}`, ...form.getHeaders() } }
      );

      const transcript = response.data?.text || "";
      return { transcript };
    } catch (e) {
      console.log("Whisper error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Transcription failed");
    }
  }
);


// Замени interviewChat и interviewFeedback в index.js:

exports.interviewChat = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 60, region: "europe-west1" },
  async (request) => {
    try {
      const messages            = request.data?.messages || [];
      const jobRole             = request.data?.jobRole || "Software Engineer";
      const interviewTypeHint   = request.data?.interviewTypeHint || "";
      const languageInstruction = request.data?.languageInstruction || "Conduct the entire interview in English.";
      const levelHint           = request.data?.levelHint || "";
      const questionIndex       = request.data?.questionIndex || 0;
      const totalQuestions      = request.data?.totalQuestions || 7;

      const apiKey = OPENAI_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing OPENAI_API_KEY secret");

      const isLastQuestion = questionIndex >= totalQuestions - 1;

      const systemPrompt = `You are a professional interviewer conducting a job interview.

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

      const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        {
          model: "gpt-4o",
          messages: [{ role: "system", content: systemPrompt }, ...messages],
          temperature: 0.7,
          max_tokens: 250,
        },
        { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } }
      );

      const reply = response.data?.choices?.[0]?.message?.content || "";
      return { reply };
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

      const apiKey = OPENAI_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing OPENAI_API_KEY secret");

      const pairs = [];
      for (let i = 0; i < messages.length - 1; i++) {
        if (messages[i].role === "assistant" && messages[i + 1].role === "user") {
          pairs.push({ question: messages[i].content, answer: messages[i + 1].content });
        }
      }

      const transcript = messages
        .map((m) => `${m.role === "user" ? "Candidate" : "Interviewer"}: ${m.content}`)
        .join("\n");

      const prompt = `
LANGUAGE INSTRUCTION: ${languageInstruction}

You are a senior HR expert analyzing a ${level} job interview for: ${jobRole}

Evaluate answers based on ${level} expectations — not too strict for Intern/Junior, more demanding for Middle/Senior.

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

      const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        {
          model: "gpt-4o",
          messages: [
            { role: "system", content: "Strict JSON generator. Return only valid JSON, no markdown." },
            { role: "user", content: prompt },
          ],
          temperature: 0.3,
          max_tokens: 1800,
        },
        { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } }
      );

      const content = response.data?.choices?.[0]?.message?.content || "";
      const cleaned = content.replace(/```json/g, "").replace(/```/g, "").trim();

      try {
        const parsed = JSON.parse(cleaned);
        if (typeof parsed.overallScore === "number") parsed.overallScore = Math.round(parsed.overallScore);
        return parsed;
      } catch {
        throw new HttpsError("internal", "GPT returned invalid JSON");
      }
    } catch (e) {
      console.log("Feedback error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Feedback failed");
    }
  }
);

exports.textToSpeech = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 60,region: "europe-west1" },
  async (request) => {
    try {
      const text = request.data?.text;
      if (!text) throw new HttpsError("invalid-argument", "text is required");

      const apiKey = OPENAI_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing OPENAI_API_KEY secret");

      console.log("TTS OpenAI request, textLength:", text.length);

      const response = await axios.post(
        "https://api.openai.com/v1/audio/speech",
        {
          model: "tts-1",
          input: text,
          voice: "nova",
          response_format: "mp3",
          speed: 1.0,
        },
        {
          headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
          },
          responseType: "arraybuffer",
        }
      );

      console.log("TTS status:", response.status);
      const audioBase64 = Buffer.from(response.data).toString("base64");
      console.log("TTS success, length:", audioBase64.length);
      return { audioBase64 };

    } catch (e) {
      const errBody = e?.response?.data
        ? Buffer.from(e.response.data).toString("utf8")
        : e.message;
      console.log("TTS error:", e?.response?.status, errBody);
      throw new HttpsError("internal", errBody || "TTS failed");
    }
  }
);


// Замени функцию visaInterviewFeedback в index.js:

exports.visaInterviewFeedback = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 90, region: "europe-west1" },
  async (request) => {
    try {
      const messages = request.data?.messages || [];
      const city     = request.data?.city || "Астана";

      const apiKey = OPENAI_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing OPENAI_API_KEY secret");

      const pairs = [];
      for (let i = 0; i < messages.length - 1; i++) {
        if (messages[i].role === "assistant" && messages[i + 1].role === "user") {
          pairs.push({ question: messages[i].content, answer: messages[i + 1].content });
        }
      }

      const transcript = messages
        .map((m) => `${m.role === "user" ? "Candidate" : "Consul"}: ${m.content}`)
        .join("\n");

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

      const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        {
          model: "gpt-4o",
          messages: [
            { role: "system", content: "Strict JSON generator. Return only valid JSON, no markdown." },
            { role: "user", content: prompt },
          ],
          temperature: 0.3,
          max_tokens: 2000,
        },
        { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } }
      );

      const content = response.data?.choices?.[0]?.message?.content || "";
      const cleaned = content.replace(/```json/g, "").replace(/```/g, "").trim();

      try {
        const parsed = JSON.parse(cleaned);
        if (typeof parsed.approvalScore === "number") parsed.approvalScore = Math.round(parsed.approvalScore);
        return parsed;
      } catch {
        throw new HttpsError("internal", "GPT returned invalid JSON");
      }
    } catch (e) {
      console.log("Visa feedback error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Visa feedback failed");
    }
  }
);