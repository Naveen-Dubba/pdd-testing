const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions';
const DEFAULT_GROQ_KEY = '';

function getApiKey() {
  // Try to load from localStorage (so user can configure it in settings) or use default
  return localStorage.getItem('groq_api_key') || import.meta.env.VITE_GROQ_KEY || DEFAULT_GROQ_KEY;
}

const SYSTEM_PROMPT = `
You are VASTRA AI, a friendly expert fashion stylist. You help people with
outfit ideas, colour pairing, what to wear for occasions (weddings, office,
casual, parties), body-type styling tips, and shopping suggestions for the
Indian market (brands available on Amazon and Flipkart).

Keep answers practical, warm, and concise. Use short paragraphs or simple
points. When suggesting items, mention colours and occasions clearly.
`;

const VISION_SYSTEM_PROMPT = `
You are an expert AI personal stylist and image analyst. You look at a single
face photo and estimate styling attributes. You ALWAYS respond with ONLY a
valid JSON object and nothing else — no markdown, no commentary.
`;

const VISION_USER_PROMPT = `
Analyze the person in this photo and return ONLY this JSON object:
{
  "gender": "Male | Female",
  "face_shape": "Oval | Round | Square | Heart | Oblong | Diamond",
  "skin_tone": "Fair | Light | Medium | Dark | Deep",
  "body_type": "best visual estimate e.g. Pear / A-Shape, Rectangle, Inverted Triangle",
  "size": "best estimate e.g. Small (S), Medium (M), Large (L)",
  "style_personality": "a short evocative style label e.g. Bohemian Rhapsody, Classic Elegance, Urban Minimal"
}
Respond with the JSON object only.
`;

export const groqService = {
  async chatCompletion(history, userMessage) {
    const key = getApiKey();
    
    // Format history for Groq
    // history format: array of { role: 'user'|'assistant', content: string }
    const messages = [
      { role: 'system', content: SYSTEM_PROMPT },
      ...history.slice(-8), // Take last 8 messages for context
      { role: 'user', content: userMessage }
    ];

    try {
      const response = await fetch(GROQ_API_URL, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${key}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: 'llama-3.1-8b-instant',
          messages: messages,
          temperature: 0.7,
          max_tokens: 1024,
          top_p: 0.9,
          stream: false
        })
      });

      if (!response.ok) {
        if (response.status === 429) {
          return "I'm getting a lot of requests right now. Please try again in a moment.";
        }
        throw new Error(`Groq API error! Status: ${response.status}`);
      }

      const data = await response.json();
      return data.choices?.[0]?.message?.content?.trim() || 'Sorry, I could not generate a reply.';
    } catch (error) {
      console.error('Groq Chat Completion failed:', error);
      return "I couldn't connect to Vastra AI right now. Please check your network and try again.";
    }
  },

  async analyzeFace(base64Image, mimeType = 'image/jpeg') {
    const key = getApiKey();
    
    // Clean up base64 prefix if present
    const base64Data = base64Image.includes('base64,') 
      ? base64Image.split('base64,')[1] 
      : base64Image;

    try {
      const response = await fetch(GROQ_API_URL, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${key}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: 'meta-llama/llama-4-scout-17b-16e-instruct',
          messages: [
            { role: 'system', content: VISION_SYSTEM_PROMPT },
            {
              role: 'user',
              content: [
                { type: 'text', text: VISION_USER_PROMPT },
                {
                  type: 'image_url',
                  image_url: {
                    url: `data:${mimeType};base64,${base64Data}`
                  }
                }
              ]
            }
          ],
          temperature: 0.4,
          max_completion_tokens: 512,
          top_p: 0.9,
          stream: false
        })
      });

      if (!response.ok) {
        throw new Error(`Groq Vision API error! Status: ${response.status}`);
      }

      const data = await response.json();
      const content = data.choices?.[0]?.message?.content?.trim();
      
      if (!content) {
        throw new Error('No content returned from Groq Vision model');
      }

      return parseJsonFromMarkdown(content);
    } catch (error) {
      console.error('Groq Vision Analysis failed:', error);
      throw error;
    }
  }
};

// Utility to extract JSON object from LLM response (handling potential markdown wrapper)
function parseJsonFromMarkdown(raw) {
  let s = raw.replace(/```json/g, '').replace(/```/g, '').trim();
  const start = s.indexOf('{');
  const end = s.lastIndexOf('}');
  
  if (start !== -1 && end !== -1 && end > start) {
    s = s.substring(start, end + 1);
  }
  
  try {
    return JSON.parse(s);
  } catch (error) {
    console.error('Failed to parse JSON content from Groq:', s);
    throw new Error('Invalid JSON format returned from analysis service.', { cause: error });
  }
}
