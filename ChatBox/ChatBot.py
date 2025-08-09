from langchain_community.vectorstores import Chroma
from langchain_huggingface import HuggingFaceEmbeddings
from LLM import GeminiLLM
import os
import time

# List of API keys
API_KEYS = [
    "AIzaSyA7uQN8rwWOZtjixq0CebiHREc9wM6-IlY",
    "AIzaSyC3zeqCQS8z0eL1e40OibSOzAdaNMeqqKg",
    "AIzaSyB8m2saY9dVnv5PdPmQI3PhA1PP35kiWZg"
]

class LLMManager:
    def __init__(self, api_keys):
        self.api_keys = api_keys
        self.current_key_index = 0
        self.max_retries = 3
        self.retry_delay = 2
        self.llm = self._initialize_llm()

    def _initialize_llm(self):
        """Initialize LLM with current API key"""
        return GeminiLLM(api_key=self.api_keys[self.current_key_index])

    def switch_key(self):
        """Switch to next available API key"""
        self.current_key_index = (self.current_key_index + 1) % len(self.api_keys)
        print(f"Chuyển sang API key mới: {self.current_key_index + 1}/{len(self.api_keys)}")
        self.llm = self._initialize_llm()

    def invoke_with_retry(self, prompt):
        """Invoke LLM with retry mechanism and key switching"""
        for attempt in range(self.max_retries):
            try:
                return self.llm.invoke(prompt)
            except Exception as e:
                if "429" in str(e) and attempt < self.max_retries - 1:
                    print(f" API quota exceeded. Switching key and retrying...")
                    self.switch_key()
                    time.sleep(self.retry_delay)
                else:
                    raise e
        raise Exception("All API keys are exhausted")

class MedicinalPlantBot:
    def __init__(self, persist_dir="vector2"):
        # Khởi tạo embedding model với cùng model đã dùng để tạo vector
        self.embedding = HuggingFaceEmbeddings(
            model_name="sentence-transformers/all-MiniLM-L6-v2",
            model_kwargs={'device': 'cpu'},
            encode_kwargs={'normalize_embeddings': False}
        )
        
        # Kiểm tra và load vectorstore
        if not os.path.exists(persist_dir):
            raise ValueError(f"Vector store directory '{persist_dir}' not found!")
            
        self.vectorstore = Chroma(
            persist_directory=persist_dir,
            embedding_function=self.embedding
        )
        
        # Khởi tạo LLM manager
        self.llm_manager = LLMManager(API_KEYS)
        print(" Đã khởi tạo ChatBot thành công!")

    def _extract_relevant_info(self, docs):
        """Trích xuất thông tin từ các documents"""
        context = []
        for doc in docs:
            content = doc.page_content
            if ':' in content:
                info = content.split(':', 1)[1].strip()
            else:
                info = content.strip()
            context.append(info)
        return '\n\n'.join(context)

    def _build_prompt(self, question, context):
        """Xây dựng prompt cho LLM"""
        return f"""
Bạn là một chuyên gia y học cổ truyền với kiến thức sâu rộng về cây thuốc, bệnh tật và phương pháp điều trị. Dưới đây là thông tin chi tiết từ cơ sở dữ liệu:

{context}

Hãy trả lời câu hỏi sau dựa trên thông tin được cung cấp:
Khi câu hỏi nói về cây có thể chữa bệnh hoặc bệnh có cây gì điều trị thì kết hợp nhiều dữ liệu được tìm thấy với nhau

Câu hỏi: {question}

Câu trả lời ít nhất 30 từ, chỉ trả lời thông tin được cung cấp.


Hãy đảm bảo câu trả lời của bạn đầy đủ, chính xác và hữu ích cho người đọc.
"""

    def _format_fallback_response(self, relevant_docs):
        """Tạo câu trả lời dự phòng khi LLM không hoạt động"""
        response = " Hiện tại không thể truy cập được dịch vụ AI. Dưới đây là thông tin liên quan từ cơ sở dữ liệu:\n\n"
        
        for i, doc in enumerate(relevant_docs, 1):
            response += f"--- Thông tin {i} ---\n"
            response += doc.page_content + "\n\n"
            
        response += "\nVui lòng thử lại sau hoặc liên hệ hỗ trợ nếu vấn đề vẫn tiếp tục."
        return response

    def ask(self, question):
        """Xử lý câu hỏi và trả về câu trả lời"""
        try:
            # Tìm kiếm thông tin liên quan
            relevant_docs = self.vectorstore.similarity_search(question, k=10)
            print("Tìm thấy thông tin liên quan từ các nguồn sau:")
            for i, doc in enumerate(relevant_docs, 1):
                print(f"{i}. {doc.metadata.get('source', 'Unknown source')}")
            
            # Trích xuất thông tin
            context = self._extract_relevant_info(relevant_docs)
            
            try:
                # Xây dựng prompt và lấy câu trả lời với LLM manager
                prompt = self._build_prompt(question, context)
                answer = self.llm_manager.invoke_with_retry(prompt)
                return answer
            except Exception as e:
                print(f" Lỗi khi gọi LLM: {str(e)}")
                return self._format_fallback_response(relevant_docs)
            
        except Exception as e:
            return f" Có lỗi xảy ra: {str(e)}"

def main():
    try:
        bot = MedicinalPlantBot()
        print("\n Chào mừng đến với ChatBot Cây Thuốc!")
        print(" Gõ 'quit' hoặc 'exit' để thoát")
        
        while True:
            question = input("\n Câu hỏi của bạn: ").strip()
            
            if question.lower() in ['quit', 'exit']:
                print("\n Tạm biệt! Hẹn gặp lại!")
                break
                
            if not question:
                print("Vui lòng nhập câu hỏi!")
                continue
                
            print("\nĐang tìm kiếm thông tin...")
            answer = bot.ask(question)
            print(f"\nTrả lời: {answer}")
            
    except Exception as e:
        print(f"Lỗi khởi tạo ChatBot: {str(e)}")

if __name__ == "__main__":
    main()
