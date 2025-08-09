import google.generativeai as genai

class GeminiLLM:
    def __init__(self, api_key: str, model_name: str = "models/gemini-1.5-flash"):
        """
        Khởi tạo Gemini LLM với API key và model name.
        """
        self.api_key = api_key
        self.model_name = model_name
        genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel(self.model_name)

    def invoke(self, prompt: str) -> str:
        """
        Gửi prompt tới mô hình Gemini và nhận kết quả trả về.
        """
        try:
            response = self.model.generate_content(prompt)
            return response.text
        except Exception as e:
            return f"Lỗi khi gọi Gemini LLM: {e}"

# Ví dụ sử dụng:
if __name__ == "__main__":
    # Khởi tạo LLM
    llm = GeminiLLM(api_key="AIzaSyB8m2saY9dVnv5PdPmQI3PhA1PP35kiWZg")

    # Prompt ví dụ
    prompt = "Giải thích ngắn gọn về cách hoạt động của trí tuệ nhân tạo."

    # Gọi mô hình và in kết quả
    output = llm.invoke(prompt)
    print("Kết quả Gemini:\n", output)
