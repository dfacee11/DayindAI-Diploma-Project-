const { onCall, HttpsError } = require("firebase-functions/v2/https");
const vision = require("@google-cloud/vision");

const client = new vision.ImageAnnotatorClient();

exports.extractTextFromImage = onCall(async (request) => {
  try {
    console.log("=== OCR FUNCTION CALLED ===");
    console.log("DATA RECEIVED:", request.data);

    const base64 = request.data?.imageBase64;

    console.log("BASE64 EXISTS:", !!base64);
    console.log("BASE64 LENGTH:", base64 ? base64.length : 0);

    if (!base64) {
      throw new HttpsError("invalid-argument", "base64 image is required");
    }

    // если base64 приходит с "data:image/png;base64,...."
    const cleanedBase64 = base64.includes("base64,")
      ? base64.split("base64,")[1]
      : base64;

    console.log("CLEANED BASE64 LENGTH:", cleanedBase64.length);

    const [result] = await client.textDetection({
      image: { content: cleanedBase64 },
    });

    const text = result.fullTextAnnotation?.text || "";

    console.log("OCR RESULT TEXT LENGTH:", text.length);

    return { text };
  } catch (e) {
    console.log("OCR error:", e);
    throw new HttpsError("internal", e.message || "OCR failed");
  }
});