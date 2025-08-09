from LLM import GeminiLLM
import os
from langchain.schema import Document
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma
import json
import re
from langchain.text_splitter import RecursiveCharacterTextSplitter
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
        self.last_call_time = 0  # Track last API call time

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
                current_time = time.time()
                time_since_last_call = current_time - self.last_call_time
                if time_since_last_call < 10:
                    sleep_time = 10 - time_since_last_call
                    print(f"Đợi {sleep_time:.1f} giây trước khi gọi API tiếp theo...")
                    time.sleep(sleep_time)
                
                result = self.llm.invoke(prompt)
                self.last_call_time = time.time()  # Update last call time
                return result
            except Exception as e:
                if "429" in str(e) and attempt < self.max_retries - 1:
                    print(f"API quota exceeded. Switching key and retrying...")
                    self.switch_key()
                    time.sleep(self.retry_delay)
                else:
                    raise e
        raise Exception("All API keys are exhausted")

# Initialize LLM manager
llm_manager = LLMManager(API_KEYS)

# Define paths
plants_folder = "data/plants"
diseases_folder = "data/diseases"
advice_folder = "data/advice"
users_folder = "data/users"
vector_dir = "vector"

# Create vector directory if it doesn't exist
os.makedirs(vector_dir, exist_ok=True)

def split_text(text, chunk_size=8000, chunk_overlap=800):
    """Split text into chunks with larger size"""
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        length_function=len,
        separators=["\n\n", "\n", ".", "!", "?", ",", " ", ""]
    )
    return text_splitter.split_text(text)

def process_documents(folder_path, doc_type='plant'):
    documents = []
    processed_files = []
    clean_chunks = []

    # Read all text files from the folder
    for filename in os.listdir(folder_path):
        if filename.endswith('.txt'):
            full_path = os.path.join(folder_path, filename)
            with open(full_path, 'r', encoding='utf-8') as file:
                content = file.read()
                documents.append(
                    Document(
                        page_content=content,
                        metadata={
                            'source': full_path,
                            'type': doc_type
                        }
                    )
                )
                processed_files.append(filename)

    # Process each document
    for i, doc in enumerate(documents):
        try:
            if doc_type == 'plant':
                prompt = f"""
                Hãy phân tích đoạn văn bản sau và trả về một JSON object duy nhất với các trường sau:
                Đọc tất cả dữ liệu và phát hiện được bệnh, mô tả, công dụng và hướng dẫn sử dụng
                {{
                    "Tên - loài": "tên cây thuốc cũng là tên loài",
                    "Tên khoa học/ tên tiếng anh": "tên khoa học hoặc tên tiếng anh",
                    "Mô tả": "mô tả chi tiết",
                    "Công dụng": "công dụng chính",
                    "Bệnh liên quan có thể chữa, điều trị hoặc hỗ trợ": "các bệnh có thể chữa, điều trị hoặc hỗ trợ",
                    "Hướng dẫn": "hướng dẫn sử dụng",
                    "Tác dụng phụ": "tác dụng phụ nếu có",
                    "Liều lượng": "liều lượng sử dụng",
                    "Cách dùng": "cách sử dụng",
                    "Lưu ý": "lưu ý khi sử dụng",
                    "Đặc điểm": "đặc điểm của cây",
                    "Phân bố": "khu vực phân bố",
                    "Bộ phận dùng": "bộ phận được sử dụng",
                    "Thu hái": "thời điểm và cách thu hái",
                    "Bài thuốc": "các bài thuốc liên quan",
                    "Chống chỉ định": "các trường hợp không nên dùng",
                    "Tương tác": "tương tác với thuốc khác",
                    "Dược tính": "tính chất dược lý",
                    "Đối tượng": "đối tượng sử dụng",
                    "Bảo quản": "cách bảo quản",
                    "Bệnh lý": "các bệnh có thể điều trị",
                    "Cập nhật": "thời gian cập nhật",
                   "phân loại": "phân loại của cây thuốc theo ngành-lớp-bộ-họ-chi-loài"
                }}

                Nếu một trường không có thông tin, hãy để giá trị là "chưa có thông tin".
                Chỉ sử dụng thông tin có trong đoạn văn bản, không thêm thông tin mới.
                Khi chia nhỏ thì luôn kèm theo tên của cây thuốc và bệnh được đề cập
            
        

                Đoạn văn bản:
                {doc.page_content}

                Trả về JSON object duy nhất, không thêm text khác.
                """
            elif doc_type == 'disease':
                prompt = f"""
                Hãy phân tích đoạn văn bản sau và trả về một JSON object duy nhất với các trường sau:
                {{
                    "Tên bệnh": "tên bệnh",
                    "Triệu chứng": "các triệu chứng chính",
                    "Nguyên nhân": "nguyên nhân gây bệnh",
                    "Biến chứng": "các biến chứng có thể xảy ra",
                    "Chẩn đoán": "phương pháp chẩn đoán",
                    "Phòng ngừa": "cách phòng ngừa bệnh",
                    "Mô tả": "mô tả chi tiết về bệnh",
                    "Cây thuốc liên quan": "các cây thuốc được đề cập",
                    "Điều trị": "phương pháp điều trị",
                    "Thuốc điều trị": "các loại thuốc được sử dụng",
                    "Tiên lượng": "tiên lượng bệnh",
                    "Cập nhật": "thời gian cập nhật",
                    
                }}

                Nếu một trường không có thông tin, hãy để giá trị là "chưa có thông tin".
                Chỉ sử dụng thông tin có trong đoạn văn bản, không thêm thông tin mới.
                Khi chia nhỏ thì luôn kèm theo tên của bệnh được đề cập

                Đoạn văn bản:
                {doc.page_content}

                Trả về JSON object duy nhất, không thêm text khác.
                """
            elif doc_type == 'advice':
                prompt = f"""
                Hãy phân tích đoạn văn bản sau và trả về một JSON object duy nhất với các trường sau:
                {{
                    "Tiêu đề": "tiêu đề lời khuyên",
                    "Nội dung": "nội dung chi tiết",
                    "Chuyên môn": "chuyên môn của tác giả",
                    "Cây thuốc liên quan": "các cây thuốc được đề cập",
                    "Bệnh liên quan": "các bệnh được đề cập",
                    "Lời khuyên": "các lời khuyên cụ thể",
                    "Lưu ý": "các lưu ý quan trọng",
                    "Cập nhật": "thời gian cập nhật"
                    "Lời khuyên của chuyên gia": "tên của chuyên gia đưa ra lời khuyên"
                }}

                Nếu một trường không có thông tin, hãy để giá trị là "chưa có thông tin".
                Chỉ sử dụng thông tin có trong đoạn văn bản, không thêm thông tin mới.
                Khi chia nhỏ thì luôn kèm theo tên của cây thuốc và tên chuyên gia đưa ra lời khuyên

                Đoạn văn bản:
                {doc.page_content}

                Trả về JSON object duy nhất, không thêm text khác.
                """
            elif doc_type == 'user':
                prompt = f"""
                Hãy phân tích đoạn văn bản sau và trả về một JSON object duy nhất với các trường sau:
                {{
                    "Họ tên": "họ và tên đầy đủ",
                    "Email": "địa chỉ email",
                    "Chức danh": "chức danh nghề nghiệp",
                    "Chuyên môn": "chuyên môn chính",
                    "Vai trò": "vai trò trong hệ thống",
                    "Trạng thái": "trạng thái hoạt động",
                    "Bằng cấp": "thông tin bằng cấp",
                    "Kinh nghiệm": "kinh nghiệm làm việc",
                    "Cập nhật": "thời gian cập nhật"
                }}

                Nếu một trường không có thông tin, hãy để giá trị là "chưa có thông tin".
                Chỉ sử dụng thông tin có trong đoạn văn bản, không thêm thông tin mới.
                Khi chia nhỏ thì luôn kèm theo tên của người dùng được đề cập

                Đoạn văn bản:
                {doc.page_content}

                Trả về JSON object duy nhất, không thêm text khác.
                """

            # Xử lý kết quả từ LLM với retry mechanism
            result = llm_manager.invoke_with_retry(prompt)
            
            # Tìm JSON object trong kết quả
            json_match = re.search(r'\{[\s\S]*\}', result)
            if not json_match:
                print(f"Không tìm thấy JSON object trong output đoạn {i+1}")
                print("Output nhận được:")
                print(result)
                continue

            json_text = json_match.group(0)
            data = json.loads(json_text)

            # Tạo Document cho từng trường
            base_name = data.get('Tên' if doc_type == 'plant' else 'Tên bệnh' if doc_type == 'disease' else 'Họ tên' if doc_type == 'user' else 'Tiêu đề', '')
            
            # Xử lý các trường thông tin
            for field, content in data.items():
                if content and content != "chưa có thông tin":
                    # Chia nhỏ nội dung dài
                    chunks = split_text(content)
                    for chunk in chunks:
                        text = f"{'Tên cây' if doc_type == 'plant' else 'Tên bệnh' if doc_type == 'disease' else 'Họ tên' if doc_type == 'user' else 'Tiêu đề'}: {base_name}\n{field}: {chunk}"
                        metadata = {
                            'source': doc.metadata['source'],
                            'type': doc_type,
                            'field': field,
                            f'{doc_type}_name': base_name,
                            'chunk_index': chunks.index(chunk)
                        }
                        doc = Document(
                            page_content=text,
                            metadata=metadata
                        )
                        clean_chunks.append(doc)

            print(f"Đã xử lý thành công {len(clean_chunks)} chunks")

        except json.JSONDecodeError as e:
            print(f"Lỗi decode JSON ở đoạn {i+1}: {e}")
            print("Output nhận được:")
            print(result)
        except Exception as e:
            print(f"Lỗi không xác định ở đoạn {i+1}: {e}")
            print("Output nhận được:")
            print(result)

    return clean_chunks, processed_files

# Initialize embedding model
model_name = "sentence-transformers/all-MiniLM-L6-v2"
model_kwargs = {'device': 'cpu'}
encode_kwargs = {'normalize_embeddings': False}

hf_embedding = HuggingFaceEmbeddings(
    model_name=model_name,
    model_kwargs=model_kwargs,
    encode_kwargs=encode_kwargs
)

# Process plants
print("\n Xử lý dữ liệu cây thuốc...")
plant_chunks, plant_files = process_documents(plants_folder, doc_type='plant')

# Process diseases
print("\n Xử lý dữ liệu bệnh...")
disease_chunks, disease_files = process_documents(diseases_folder, doc_type='disease')

# Process advice
print("\n Xử lý dữ liệu lời khuyên...")
advice_chunks, advice_files = process_documents(advice_folder, doc_type='advice')

# Process users
print("\nXử lý dữ liệu người dùng...")
user_chunks, user_files = process_documents(users_folder, doc_type='user')

# Combine all chunks
all_chunks = plant_chunks + disease_chunks + advice_chunks + user_chunks

# Create and save combined vectorstore
vectorstore = Chroma.from_documents(
    documents=all_chunks,
    embedding=hf_embedding,
    persist_directory=vector_dir
)

print("\nDanh sách các file đã được tạo vector:")
print("\nCây thuốc:")
for i, filename in enumerate(plant_files, 1):
    print(f"{i}. {filename}")

print("\nBệnh:")
for i, filename in enumerate(disease_files, 1):
    print(f"{i}. {filename}")

print("\nLời khuyên:")
for i, filename in enumerate(advice_files, 1):
    print(f"{i}. {filename}")

print("\nNgười dùng:")
for i, filename in enumerate(user_files, 1):
    print(f"{i}. {filename}")