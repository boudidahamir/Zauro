# ZAURO: AI + Hedera Workflow (Breed → Age → Disease → Blockchain + NFT)

import os
import json
import datetime
import requests
# from hedera import (Client, TopicMessageSubmitTransaction, AccountId, PrivateKey)
from inference_sdk import InferenceHTTPClient
# --- Config ---
ROBOFLOW_API_KEY = "<your_roboflow_api_key>"
ROBOFLOW_MODEL_ID = "sliit-kuemd/cattle-diseases"
ROBOFLOW_VERSION = "1"
ROBOFLOW_URL = f"https://detect.roboflow.com/{ROBOFLOW_MODEL_ID}/{ROBOFLOW_VERSION}"

# --- 1. Breed Detection (mock or from YesChat API if available) ---
def detect_breed(image_path):
    print(f"[AI] Simulated breed detection on: {image_path}")
    return "White Fulani", 0.89  # mock breed + confidence

# --- 2. Age & Sex Estimation (heuristic) ---
def estimate_age_sex(breed):
    age = 2.5 if "Fulani" in breed else 1.5
    sex = "female" if "cow" in breed.lower() else "male"
    return age, sex

# --- 3. Disease Detection using Roboflow API ---
def detect_disease_with_roboflow(image_path):
    with open(image_path, "rb") as img:
        resp = requests.post(
            f"{ROBOFLOW_URL}",
            params={"api_key": ROBOFLOW_API_KEY},
            files={"file": img}
        )
    data = resp.json()
    preds = data.get("predictions", [])
    if preds:
        return preds[0]["class"], preds[0]["confidence"]
    return "healthy", 0.0

def detect_disease_with_roboflow_mock(image_path):
    CLIENT = InferenceHTTPClient(
    api_url="https://serverless.roboflow.com",
    api_key="YPeeLeEnmBBMD2yGzdZW"
)

result = CLIENT.infer(your_image.jpg, model_id="cattle-diseases/1")
# --- 4. Metadata Builder ---
def build_metadata(animal_id, breed, breed_conf, age, sex, disease, disease_conf):
    return {
        "animal_id": animal_id,
        "timestamp": datetime.datetime.utcnow().isoformat(),
        "breed": breed,
        "breed_confidence": breed_conf,
        "age": age,
        "sex": sex,
        "disease": disease,
        "disease_confidence": disease_conf,
        "health_status": "critical" if disease != "healthy" else "ok"
    }

# --- 5. Log to Hedera ---
# def log_to_hedera(metadata_json):
#     account_id = os.getenv("ACCOUNT_ID")
#     private_key = os.getenv("PRIVATE_KEY")
#     topic_id = os.getenv("TOPIC_ID")

#     client = Client.forTestnet()
#     client.setOperator(AccountId.fromString(account_id), PrivateKey.fromString(private_key))

#     tx = TopicMessageSubmitTransaction()\
#         .setTopicId(topic_id)\
#         .setMessage(json.dumps(metadata_json))\
#         .execute(client)

#     print("[Hedera] Metadata submitted. TxID:", tx.transactionId)

# --- 6. NFT Placeholder ---
# def mint_nft(metadata_json, image_path):
#     print(f"[NFT] Minting NFT for: {metadata_json['animal_id']}")
#     print("[NFT] Simulated NFT minted with metadata.")

# --- 7. Run Full Pipeline ---
def run_pipeline(image_path, animal_id="ZAURO-001"):
    print("[Pipeline] Processing image:", image_path)
    breed, breed_conf = detect_breed(image_path)
    age, sex = estimate_age_sex(breed)
    disease, disease_conf = detect_disease_with_roboflow(image_path)

    metadata = build_metadata(animal_id, breed, breed_conf, age, sex, disease, disease_conf)
    print("[Pipeline] Metadata built:", json.dumps(metadata, indent=2))
    # log_to_hedera(metadata)
    # mint_nft(metadata, image_path)

if __name__ == "__main__":
    # Set environment variables or replace manually
    os.environ["ACCOUNT_ID"] = "<your-testnet-account-id>"
    os.environ["PRIVATE_KEY"] = "<your-private-key>"
    os.environ["TOPIC_ID"] = "<your-topic-id>"

    run_pipeline("sample_cow.jpg")
