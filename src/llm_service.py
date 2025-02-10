import os
import logging
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
genai.configure(api_key=os.environ["GEMINI_API_KEY"])

logger = logging.getLogger(__name__)

class LLMService:
    """LLM model- Gemini"""

    def __init__(self):
        print("Loading Gemini config...")
        self.generation_config = {
            "temperature": 1,
            "top_p": 0.95,
            "top_k": 40,
            "max_output_tokens": 8192,
            "response_mime_type": "text/plain",
        }
        self.model = genai.GenerativeModel(
            model_name="gemini-2.0-flash-exp",
            generation_config=self.generation_config,
        )

    def generate_report(self, prompt):
        """Generates a report using the LLM based on analysis data provided"""

        try:
            response = self.model.generate_content(prompt)
            print("LLM Report Generated")

            return response.text
        except Exception as e:
            logger.error(f"LLM generation error: {str(e)}")
            raise