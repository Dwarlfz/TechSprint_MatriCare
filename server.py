from flask import Flask, jsonify
from flask_cors import CORS
import pandas as pd
import os
import threading
import time
import random

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

CSV_FILE_PATH = '../maternal_training_data.csv'  # Path relative to where server.py is run (inside Doctor folder)

# Global variable to store current data
current_data = []

def load_initial_data():
    global current_data
    if os.path.exists(CSV_FILE_PATH):
        df = pd.read_csv(CSV_FILE_PATH)
        current_data = df.to_dict(orient='records')
        print(f"Loaded {len(current_data)} records.")
    else:
        print("CSV file not found.")

def generate_patient_data():
    """
    Background thread to update patient data every 2 minutes.
    Updates specific patients with different risk profiles.
    """
    global current_data
    while True:
        if len(current_data) >= 3:
            print("Updating patient data...")
            
            # Patient 1: Normal Risk (Index 0)
            # Fetal HR: 120-160, Maternal HR: 70-90, BP: 110/70 - 120/80
            current_data[0]['fetalHeartRate'] = random.randint(120, 160)
            current_data[0]['maternalHeartRate'] = random.randint(70, 90)
            systolic_normal = random.randint(110, 120)
            diastolic_normal = random.randint(70, 80)
            current_data[0]['bloodPressure'] = f"{systolic_normal}/{diastolic_normal}" # Assuming string format in CSV/Frontend
            current_data[0]['fetalMovement'] = random.randint(30, 50) # Normal movement

            # Patient 2: Medium Risk (Index 1)
            # Fetal HR: 150-170, Maternal HR: 85-100, BP: 125/80 - 135/90
            current_data[1]['fetalHeartRate'] = random.randint(150, 170)
            current_data[1]['maternalHeartRate'] = random.randint(85, 100)
            systolic_med = random.randint(125, 135)
            diastolic_med = random.randint(80, 90)
            current_data[1]['bloodPressure'] = f"{systolic_med}/{diastolic_med}"
            current_data[1]['fetalMovement'] = random.randint(20, 40) # Slightly lower

            # Patient 3: High Risk (Index 2)
            # Fetal HR: 170-190, Maternal HR: 100-120, BP: 140/90 - 160/100
            current_data[2]['fetalHeartRate'] = random.randint(170, 190)
            current_data[2]['maternalHeartRate'] = random.randint(100, 120)
            systolic_high = random.randint(140, 160)
            diastolic_high = random.randint(90, 100)
            current_data[2]['bloodPressure'] = f"{systolic_high}/{diastolic_high}"
            current_data[2]['fetalMovement'] = random.randint(5, 20) # Low movement

        time.sleep(120) # Update every 2 minutes

@app.route('/api/data', methods=['GET'])
def get_data():
    try:
        if not current_data:
             return jsonify({'error': 'No data available'}), 404
        
        return jsonify(current_data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    load_initial_data()
    
    # Start background thread
    data_thread = threading.Thread(target=generate_patient_data, daemon=True)
    data_thread.start()
    
    print(f"Starting server... Watching {os.path.abspath(CSV_FILE_PATH)}")
    app.run(debug=True, port=5000)
