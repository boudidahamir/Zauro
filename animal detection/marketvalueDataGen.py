import json
import random

# Possible values
sexes = ["Male", "Female"]
ages = [f"{i}Y" for i in range(1, 15)]
diseases_list = ["healthy", "Dermatitis", "Ecthym", "Respiratory", "lumpy", "Skin"]

def calculate_price(sex, age, diseases):
    age_num = int(age.replace("Y", ""))
    base_price = 5000 - age_num * 300
    if sex == "Male":
        base_price += 200
    if "healthy" not in diseases:
        base_price -= 500
    return max(base_price + random.randint(-200, 200), 1000)

def generate_entry():
    sex = random.choice(sexes)
    age = random.choice(ages)
    diseases = ["healthy"] if random.random() < 0.7 else random.sample(diseases_list[1:], random.randint(1, 2))
    price = calculate_price(sex, age, diseases)

    return {
        "input": {
            "sex": sex,
            "age": age,
            "health": diseases
        },
        "output": price
    }

def generate_dataset(n=100):
    dataset = [generate_entry() for _ in range(n)]
    with open("cattle_training_dataset.json", "w") as f:
        json.dump(dataset, f, indent=4)
    print("✅ cattle_training_dataset.json created")

# Run
if __name__ == "__main__":
    generate_dataset(n=1000)
