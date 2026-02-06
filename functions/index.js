const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const vision = require("@google-cloud/vision");
const axios = require("axios");

const DEEPSEEK_API_KEY = defineSecret("DEEPSEEK_API_KEY");
const client = new vision.ImageAnnotatorClient();

/**
 * 1) OCR FUNCTION
 */
exports.extractTextFromImage = onCall(async (request) => {
  try {
    const base64 = request.data?.imageBase64;

    if (!base64) {
      throw new HttpsError("invalid-argument", "base64 image is required");
    }

    const cleanedBase64 = base64.includes("base64,")
      ? base64.split("base64,")[1]
      : base64;

    const [result] = await client.textDetection({
      image: { content: cleanedBase64 },
    });

    const text = result.fullTextAnnotation?.text || "";

    return { text };
  } catch (e) {
    console.log("OCR error:", e);
    throw new HttpsError("internal", e.message || "OCR failed");
  }
});

/**
 * 2) RESUME ANALYSIS (DeepSeek)
 */
exports.analyzeResumeDeepseek = onCall(
  { secrets: [DEEPSEEK_API_KEY] },
  async (request) => {
    try {
      const text = request.data?.text;
      const profession = request.data?.profession;

      if (!text || text.trim().length < 30) {
        throw new HttpsError("invalid-argument", "Resume text is too short");
      }

      if (!profession) {
        throw new HttpsError("invalid-argument", "Profession is required");
      }

      const apiKey = DEEPSEEK_API_KEY.value();

      if (!apiKey) {
        throw new HttpsError("internal", "Missing DEEPSEEK_API_KEY secret");
      }

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
            {
              role: "system",
              content:
                "You are a strict JSON generator. Return only valid JSON.",
            },
            { role: "user", content: prompt },
          ],
          temperature: 0.3,
        },
        {
          headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
          },
        }
      );

      const content = response.data?.choices?.[0]?.message?.content;

      if (!content) {
        throw new HttpsError("internal", "Empty DeepSeek response");
      }

      const cleaned = content
        .replace(/```json/g, "")
        .replace(/```/g, "")
        .trim();

      let parsed;
      try {
        parsed = JSON.parse(cleaned);
      } catch (err) {
        console.log("RAW DEEPSEEK RESPONSE:", content);
        throw new HttpsError("internal", "DeepSeek returned invalid JSON");
      }

      return parsed;
    } catch (e) {
      console.log("Analyze error:", e);
      throw new HttpsError("internal", e.message || "Analyze failed");
    }
  }
);