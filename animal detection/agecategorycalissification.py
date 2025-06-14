import os
import random
import shutil
from PIL import Image, UnidentifiedImageError

INPUT_FOLDER = "C://Users//amirb//Downloads//images"
OUTPUT_FOLDER = "categorized_cows"
AGE_CATEGORIES = ["1Y", "2Y", "3Y", "4Y", "5Y", "6Y", "7Y", "8Y", "9Y", "10Y", "11Y", "12Y", "13Y", "14Y", "15Y"]

# Create folders
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
for category in AGE_CATEGORIES:
    os.makedirs(os.path.join(OUTPUT_FOLDER, category), exist_ok=True)

# Collect valid image files (even without extensions)
valid_images = []
for root, _, files in os.walk(INPUT_FOLDER):
    for file in files:
        full_path = os.path.join(root, file)
        try:
            with Image.open(full_path) as img:
                img.verify()  # verify the file is a valid image
                valid_images.append(full_path)
        except (UnidentifiedImageError, IOError):
            pass  # skip non-image files

# Randomly assign to categories
for img_path in valid_images:
    chosen_category = random.choice(AGE_CATEGORIES)
    file_name = os.path.basename(img_path)
    dst_path = os.path.join(OUTPUT_FOLDER, chosen_category, file_name)
    shutil.copyfile(img_path, dst_path)

print(f"✅ Done! Categorized {len(valid_images)} images into {len(AGE_CATEGORIES)} folders.")
