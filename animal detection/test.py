import requests
from PIL import Image
import base64
import io

# === Configurations ===
ROBOFLOW_DISEASE_API_KEY = "YPeeLeEnmBBMD2yGzdZW"
ROBOFLOW_DISEASE_PROJECT = "cattle-diseases-y4k4x"
ROBOFLOW_MODEL_VERSION = "1"
ROBOFLOW_SEX_API_KEY = "YPeeLeEnmBBMD2yGzdZW"
ROBOFLOW_SEX_PROJECT = "bull-model-olp2r"
ROBOFLOW_AGE_API_KEY = "YPeeLeEnmBBMD2yGzdZW"
ROBOFLOW_AGE_PROJECT = "cattle-age"

# === Utility: Convert image to base64 ===
def image_to_base64(image_path):
    with open(image_path, "rb") as img_file:
        return base64.b64encode(img_file.read()).decode('utf-8')

# === Step 1: Age & Sex Detection ===

def detect_sex_roboflow(image_path):
    url = f"https://detect.roboflow.com/{ROBOFLOW_SEX_PROJECT}/{ROBOFLOW_MODEL_VERSION}?api_key={ROBOFLOW_SEX_API_KEY}"
    
    with open(image_path, "rb") as image_file:
        response = requests.post(url, files={"file": image_file})

    try:
        result = response.json()
        print("🧪 Roboflow Raw Result:", result)

        predictions = result.get("predictions", [])
        if not predictions:
            return "Female"  # Assume female if no Scrotum detected

        classes = [pred["class"] for pred in predictions]
        return "Male" if "Scrotum" in classes else "Female"

    except Exception as e:
        print("❌ Error parsing response:", e)
        return "Error during detection"

# === Step 2: Cattle Disease Detection via Roboflow ===

def detect_disease_roboflow(image_path):
    url = f"https://detect.roboflow.com/{ROBOFLOW_DISEASE_PROJECT}/{ROBOFLOW_MODEL_VERSION}?api_key={ROBOFLOW_DISEASE_API_KEY}"
    with open(image_path, "rb") as image_file:
        response = requests.post(url, files={"file": image_file})

    try:
        result = response.json()
        print("🧪 Roboflow Raw Result:", result)

        predicted_classes = result.get("predicted_classes")
        if not predicted_classes:
            return "No disease detected"

        return list(set(predicted_classes))
    except Exception as e:
        print("❌ Error parsing response:", e)
        return "Error during detection"

# === MAIN FUNCTION ===
def analyze_cattle(image_path):
    print("🔍 Analyzing image:", image_path)
    
    # Step 1: Age & Sex (mocked)
    sex = detect_sex_roboflow(image_path)
    age = detect_age_roboflow(image_path)
    print(f"📌 Age Detected: {age}")
    print(f"📌 Sex Detected: {sex}")

    # Step 2: Disease Detection
    diseases = detect_disease_roboflow(image_path)
    print(f"💉 Detected Diseases: {diseases}")

    return {
        "sex": sex,
        "age": age,
        "health": diseases,
    }

def detect_age_roboflow(image_path):
    url = f"https://detect.roboflow.com/{ROBOFLOW_AGE_PROJECT}/{ROBOFLOW_MODEL_VERSION}?api_key={ROBOFLOW_AGE_API_KEY}&confidence=0.1"
    
    with open(image_path, "rb") as image_file:
        response = requests.post(url, files={"file": image_file})

    try:
        result = response.json()
        print("🧪 Roboflow Raw Result:", result)

        predictions = result.get("predictions", [])
        if not predictions:
            return "Unknown"

        # Get the class of the first prediction (highest ranked)
        first_class = predictions[0].get("class", "Unknown")
        return first_class

    except Exception as e:
        print("❌ Error parsing response:", e)
        return "Error during detection"
# === Example Usage ===
if __name__ == "__main__":
    image_path = "download (1).jpg"  # Replace with your image path
    results = analyze_cattle(image_path)
    print(results)
