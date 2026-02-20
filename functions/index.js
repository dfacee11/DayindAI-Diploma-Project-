const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const vision = require("@google-cloud/vision");
const axios = require("axios");
const FormData = require("form-data");

const DEEPSEEK_API_KEY = defineSecret("DEEPSEEK_API_KEY");
const OPENAI_API_KEY   = defineSecret("OPENAI_API_KEY");
const ELEVENLABS_API_KEY = defineSecret("ELEVENLABS_API_KEY");

const client = new vision.ImageAnnotatorClient();

// ─────────────────────────────────────────────
// 1) OCR
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// 2) RESUME ANALYZE (DeepSeek)
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// 3) RESUME MATCHING (DeepSeek)
// ─────────────────────────────────────────────
exports.matchResumeDeepseek = onCall(
  { secrets: [DEEPSEEK_API_KEY] },
  async (request) => {
    try {
      const resumeText = request.data?.resumeText;
      const jobText    = request.data?.jobText;

      if (!resumeText || resumeText.trim().length < 30) throw new HttpsError("invalid-argument", "Resume text is too short");
      if (!jobText    || jobText.trim().length    < 30) throw new HttpsError("invalid-argument", "Job text is too short");

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

// ─────────────────────────────────────────────
// 4) STT — Whisper (OpenAI)
//    Принимает: { audioBase64: string, mimeType: string }
//    Возвращает: { transcript: string }
// ─────────────────────────────────────────────
exports.transcribeAudio = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 60 },
  async (request) => {
    try {
      const audioBase64 = request.data?.audioBase64;
      const mimeType    = request.data?.mimeType || "audio/m4a";

      if (!audioBase64) throw new HttpsError("invalid-argument", "audioBase64 is required");

      const apiKey = OPENAI_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing OPENAI_API_KEY secret");

      const buffer = Buffer.from(audioBase64, "base64");

      const form = new FormData();
      form.append("file", buffer, { filename: "audio.m4a", contentType: mimeType });
      form.append("model", "whisper-1");
      form.append("language", "en");

      const response = await axios.post(
        "https://api.openai.com/v1/audio/transcriptions",
        form,
        {
          headers: {
            Authorization: `Bearer ${apiKey}`,
            ...form.getHeaders(),
          },
        }
      );

      const transcript = response.data?.text || "";
      return { transcript };
    } catch (e) {
      console.log("Whisper error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Transcription failed");
    }
  }
);

// ─────────────────────────────────────────────
// 5) AI INTERVIEW — GPT-4o
//    Принимает: { messages: [{role, content}], jobRole: string, questionIndex: int, totalQuestions: int }
//    Возвращает: { reply: string, isFinished: bool, feedback: string|null }
// ─────────────────────────────────────────────
exports.interviewChat = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 60 },
  async (request) => {
    try {
      const messages       = request.data?.messages || [];
      const jobRole        = request.data?.jobRole || "Software Engineer";
      const questionIndex  = request.data?.questionIndex || 0;
      const totalQuestions = request.data?.totalQuestions || 7;

      const apiKey = OPENAI_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing OPENAI_API_KEY secret");

      const isLastQuestion = questionIndex >= totalQuestions - 1;

      const systemPrompt = `You are a professional interviewer conducting a job interview for the role: ${jobRole}.

Rules:
- Ask ONE question at a time
- Keep responses concise (2-4 sentences max)
- Be professional but friendly
- Question ${questionIndex + 1} of ${totalQuestions}
${isLastQuestion
  ? `- This is the LAST question. After the candidate answers, provide a brief encouraging closing statement and say the interview is complete.`
  : `- After the candidate answers, acknowledge briefly and ask the next interview question.`
}
- Do NOT number your questions out loud
- Focus on behavioral and technical questions relevant to ${jobRole}`;

      const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        {
          model: "gpt-4o",
          messages: [
            { role: "system", content: systemPrompt },
            ...messages,
          ],
          temperature: 0.7,
          max_tokens: 200,
        },
        { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } }
      );

      const reply = response.data?.choices?.[0]?.message?.content || "";
      const isFinished = isLastQuestion && messages.length > totalQuestions * 2;

      return { reply, isFinished };
    } catch (e) {
      console.log("Interview chat error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Interview failed");
    }
  }
);

// ─────────────────────────────────────────────
// 6) INTERVIEW FEEDBACK — GPT-4o
//    Принимает: { messages: [{role, content}], jobRole: string }
//    Возвращает: { overallScore, strengths, improvements, verdict }
// ─────────────────────────────────────────────
exports.interviewFeedback = onCall(
  { secrets: [OPENAI_API_KEY], timeoutSeconds: 60 },
  async (request) => {
    try {
      const messages = request.data?.messages || [];
      const jobRole  = request.data?.jobRole || "Software Engineer";

      const apiKey = OPENAI_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing OPENAI_API_KEY secret");

      const transcript = messages
        .map((m) => `${m.role === "user" ? "Candidate" : "Interviewer"}: ${m.content}`)
        .join("\n");

      const prompt = `
Analyze this job interview for the role: ${jobRole}

Interview transcript:
${transcript}

Return ONLY valid JSON:
{
  "overallScore": 0-100,
  "strengths": ["strength1", "strength2", "strength3"],
  "improvements": ["area1", "area2", "area3"],
  "verdict": "Hire" | "Maybe" | "No Hire",
  "summary": "2-3 sentence overall assessment"
}
`;

      const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        {
          model: "gpt-4o",
          messages: [
            { role: "system", content: "You are a strict JSON generator. Return only valid JSON." },
            { role: "user", content: prompt },
          ],
          temperature: 0.3,
          max_tokens: 500,
        },
        { headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" } }
      );

      const content = response.data?.choices?.[0]?.message?.content || "";
      const cleaned = content.replace(/```json/g, "").replace(/```/g, "").trim();

      try {
        return JSON.parse(cleaned);
      } catch {
        throw new HttpsError("internal", "GPT returned invalid JSON");
      }
    } catch (e) {
      console.log("Feedback error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "Feedback failed");
    }
  }
);

// ─────────────────────────────────────────────
// 7) TTS — ElevenLabs
//    Принимает: { text: string, voiceId?: string }
//    Возвращает: { audioBase64: string }
// ─────────────────────────────────────────────
exports.textToSpeech = onCall(
  { secrets: [ELEVENLABS_API_KEY], timeoutSeconds: 60 },
  async (request) => {
    try {
      const text    = request.data?.text;
      // Rachel — профессиональный женский голос ElevenLabs
      const voiceId = request.data?.voiceId || "21m00Tcm4TlvDq8ikWAM";

      if (!text) throw new HttpsError("invalid-argument", "text is required");

      const apiKey = ELEVENLABS_API_KEY.value();
      if (!apiKey) throw new HttpsError("internal", "Missing ELEVENLABS_API_KEY secret");

      const response = await axios.post(
        `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`,
        {
          text,
          model_id: "eleven_flash_v2_5",
          voice_settings: { stability: 0.5, similarity_boost: 0.75 },
        },
        {
          headers: {
            "xi-api-key": apiKey,
            "Content-Type": "application/json",
            Accept: "audio/mpeg",
          },
          responseType: "arraybuffer",
        }
      );

      const audioBase64 = Buffer.from(response.data).toString("base64");
      return { audioBase64 };
    } catch (e) {
      console.log("TTS error:", e?.response?.data || e.message);
      throw new HttpsError("internal", e.message || "TTS failed");
    }
  }
);