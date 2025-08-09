import os
import re
import requests

# API endpoints
PLANTS_URL = 'https://medicalplant.apivui.click/api/plants'
SPECIES_URL = 'https://medicalplant.apivui.click/api/species'
GENUS_URL = 'https://medicalplant.apivui.click/api/genus'
FAMILY_URL = 'https://medicalplant.apivui.click/api/family'
ORDER_URL = 'https://medicalplant.apivui.click/api/orders'
CLASS_URL = 'https://medicalplant.apivui.click/api/classes'
DIVISION_URL = 'https://medicalplant.apivui.click/api/divisions'
DISEASES_URL = 'https://medicalplant.apivui.click/api/diseases'
ADVICE_URL = 'https://medicalplant.apivui.click/api/advice'
USER_URL = 'https://medicalplant.apivui.click/api/users'

def setup_folders():
    """Create necessary folders for data storage"""
    plants_folder = "data/plants"
    diseases_folder = "data/diseases"
    advice_folder = "data/advice"
    users_folder = "data/users"
    os.makedirs(plants_folder, exist_ok=True)
    os.makedirs(diseases_folder, exist_ok=True)
    os.makedirs(advice_folder, exist_ok=True)
    os.makedirs(users_folder, exist_ok=True)
    return plants_folder, diseases_folder, advice_folder, users_folder

def normalize_filename(name):
    """Normalize filename by removing invalid characters"""
    return re.sub(r'[\\/*?:"<>|]', "", name).strip()

def clean_text(text):
    """Clean text by removing extra whitespace and handling empty text"""
    if not text:
        return "chưa có thông tin"
    return re.sub(r'\n\s*\n+', '\n\n', text.strip())

def get_taxonomic_data(species_id):
    """Get taxonomic data for a plant species"""
    # Get species data
    species_response = requests.get(f"{SPECIES_URL}/{species_id}")
    if species_response.status_code != 200:
        return None
    
    species_data = species_response.json()
    genus_id = species_data.get('genus_id')
    
    # Get genus data
    genus_response = requests.get(f"{GENUS_URL}/{genus_id}")
    if genus_response.status_code != 200:
        return None
    
    genus_data = genus_response.json()
    family_id = genus_data.get('family_id')
    
    # Get family data
    family_response = requests.get(f"{FAMILY_URL}/{family_id}")
    if family_response.status_code != 200:
        return None
    
    family_data = family_response.json()
    order_id = family_data.get('order_id')
    
    # Get order data
    order_response = requests.get(f"{ORDER_URL}/{order_id}")
    if order_response.status_code != 200:
        return None
    
    order_data = order_response.json()
    class_id = order_data.get('class_id')
    
    # Get class data
    class_response = requests.get(f"{CLASS_URL}/{class_id}")
    if class_response.status_code != 200:
        return None
    
    class_data = class_response.json()
    division_id = class_data.get('division_id')
    
    # Get division data
    division_response = requests.get(f"{DIVISION_URL}/{division_id}")
    if division_response.status_code != 200:
        return None
    
    division_data = division_response.json()
    
    return {
        'species': species_data,
        'genus': genus_data,
        'family': family_data,
        'order': order_data,
        'class': class_data,
        'division': division_data
    }

def save_plant_data(plants_folder):
    """Fetch and save plant data"""
    response = requests.get(PLANTS_URL)
    if response.status_code != 200:
        print(f" Lỗi khi truy cập API cây thuốc: {response.status_code}")
        return

    plants = response.json()
    for plant in plants:
        name = plant.get('name', 'unknown')
        filename = normalize_filename(name) + ".txt"
        filepath = os.path.join(plants_folder, filename)
        
        # Get taxonomic data
        taxonomic_data = get_taxonomic_data(plant.get('species_id'))
        
        content = f"""
Tên tiếng Việt: {plant.get('name', '')}
Tên tiếng Anh: {plant.get('english_name', '')}
Thời gian cập nhật: {plant.get('updated_at', '')}

Phân loại:
- Ngành: {taxonomic_data['division']['name'] if taxonomic_data else 'Chưa có thông tin'}
- Lớp: {taxonomic_data['class']['name'] if taxonomic_data else 'Chưa có thông tin'}
- Bộ: {taxonomic_data['order']['name'] if taxonomic_data else 'Chưa có thông tin'}
- Họ: {taxonomic_data['family']['name'] if taxonomic_data else 'Chưa có thông tin'}
- Chi: {taxonomic_data['genus']['name'] if taxonomic_data else 'Chưa có thông tin'}
- Loài: {taxonomic_data['species']['name'] if taxonomic_data else 'Chưa có thông tin'}

Mô tả: {clean_text(plant.get('description', ''))}

Công dụng: {clean_text(plant.get('benefits', ''))}

Hướng dẫn sử dụng: {clean_text(plant.get('instructions', ''))}
        """.strip()

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"Đã lưu cây: {filename}")

def save_disease_data(diseases_folder):
    """Fetch and save disease data"""
    response = requests.get(DISEASES_URL)
    if response.status_code != 200:
        print(f" Lỗi khi truy cập API bệnh: {response.status_code}")
        return

    diseases = response.json()
    for disease in diseases:
        name = disease.get('name', 'unknown')
        filename = normalize_filename(name) + ".txt"
        filepath = os.path.join(diseases_folder, filename)
        
        content = f"""
Tên bệnh: {disease.get('name', '')}
Thời gian cập nhật: {disease.get('updated_at', '')}

Mô tả: {clean_text(disease.get('description', ''))}

Triệu chứng: {clean_text(disease.get('symptoms', ''))}

Hướng dẫn điều trị: {clean_text(disease.get('instructions', ''))}
        """.strip()
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"Đã lưu bệnh: {filename}")

def save_advice_data(advice_folder):
    """Fetch and save advice data"""
    response = requests.get(ADVICE_URL)
    if response.status_code != 200:
        print(f" Lỗi khi truy cập API lời khuyên: {response.status_code}")
        return

    advice_list = response.json()
    for advice in advice_list:
        title = advice.get('title', 'unknown')
        filename = normalize_filename(title) + ".txt"
        filepath = os.path.join(advice_folder, filename)
        
        # Get related plant and disease information with null checks
        related_plant = advice.get('plant') or {}
        related_disease = advice.get('disease') or {}
        user = advice.get('user') or {}
        
        content = f"""
Tiêu đề: {advice.get('title', '')}
Thời gian cập nhật: {advice.get('updated_at', '')}

Nội dung: {clean_text(advice.get('content', ''))}

Thông tin người đăng:
- Họ tên: {user.get('full_name', 'Chưa có thông tin')}
- Chức danh: {user.get('title', 'Chưa có thông tin')}

Thông tin liên quan:
"""
        if related_plant:
            content += f"""
Cây thuốc liên quan:
- Tên: {related_plant.get('name', 'Chưa có thông tin')}
"""
        
        if related_disease:
            content += f"""
Bệnh liên quan:
- Tên: {related_disease.get('name', 'Chưa có thông tin')}
"""
        
        content = content.strip()
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f" Đã lưu lời khuyên: {filename}")

def save_user_data(users_folder):
    """Fetch and save user data"""
    response = requests.get(USER_URL)
    if response.status_code != 200:
        print(f" Lỗi khi truy cập API người dùng: {response.status_code}")
        return

    try:
        # Parse the response text as JSON
        users_data = response.json()
        # Extract the users array from the response
        users = users_data.get('data', [])
        
        for user in users:
            name = user.get('full_name', 'unknown')
            filename = normalize_filename(name) + ".txt"
            filepath = os.path.join(users_folder, filename)
            
            role = user.get('role', {})
            
            content = f"""
Họ tên: {user.get('full_name', '')}
Email: {user.get('email', '')}
Chức danh: {user.get('title', '')}
Chuyên môn: {user.get('specialty', '')}
Trạng thái: {'Đang hoạt động' if user.get('active') else 'Không hoạt động'}
Vai trò: {role.get('name', '')}

Thông tin bổ sung:
- Avatar: {user.get('avatar', 'Chưa có')}
- Bằng cấp: {user.get('proof', 'Chưa có')}

Thời gian:
- Tạo lúc: {user.get('created_at', '')}
- Cập nhật: {user.get('updated_at', '')}
            """.strip()
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"Đã lưu người dùng: {filename}")
    except Exception as e:
        print(f"Lỗi khi xử lý dữ liệu người dùng: {str(e)}")

def main():
    """Main function to run the data fetching process"""
    print("Bắt đầu quá trình lấy dữ liệu...")
    
    # # Setup folders
    # plants_folder, diseases_folder, advice_folder, users_folder = setup_folders()
    
    # # Fetch and save plant data
    # print("\nĐang lấy dữ liệu cây thuốc...")
    # save_plant_data(plants_folder)
    
    # # Fetch and save disease data
    # print("\nĐang lấy dữ liệu bệnh...")
    # save_disease_data(diseases_folder)
    
    # # Fetch and save advice data
    # print("\nĐang lấy dữ liệu lời khuyên...")
    # save_advice_data(advice_folder)
    
    # Fetch and save user data
    _, _, _, users_folder = setup_folders()
    print("\nĐang lấy dữ liệu người dùng...")
    save_user_data(users_folder)
    
    print("\nHoàn thành quá trình lấy dữ liệu!")

if __name__ == "__main__":
    main()
