#  MatriCare – AI-Enabled Maternal Health Monitoring System

## 📌 Overview

**MatriCare** is an AI-powered maternal health monitoring system designed to provide **continuous, real-time pregnancy monitoring** outside hospital environments. It combines a **wearable device**, **mobile application**, and **doctor web dashboard** to enable early detection of risks and improve maternal and fetal outcomes—especially in rural and semi-urban regions.

The system focuses on preventive care by identifying early warning signs such as hypertension, fetal distress, and abnormal contractions before they become life-threatening.

---

## 🎯 Problem Statement

Maternal healthcare still faces major challenges due to:

* Lack of continuous monitoring outside hospitals
* Delayed diagnosis of pregnancy complications
* Limited access to healthcare in rural and semi-urban areas
* High dependency on periodic hospital visits

According to WHO, **800+ maternal deaths occur daily worldwide**, many of which are preventable through early detection and timely care.

---

## 💡 Proposed Solution

MatriCare offers an **end-to-end maternal monitoring ecosystem** consisting of:

* A **wearable device** for continuous vitals tracking
* An **AI-based risk assessment engine**
* A **mobile app** for mothers
* A **web dashboard** for doctors

The system categorizes health conditions into:

* 🟢 Normal
* 🟡 Warning
* 🔴 Emergency

Instant alerts ensure timely intervention and reduce medical emergencies.

---

## 🧠 Key Features

### 🔹 Wearable Device

* Tracks:

  * Maternal heart rate
  * Fetal heart rate
  * Body temperature
  * SpO₂ levels
  * Uterine contractions
* Lightweight and skin-friendly
* 24–48 hours battery backup
* Built using low-cost biosensors and ESP32

---

### 🔹 Mobile Application (Patient)

* Real-time vitals dashboard
* Instant alerts and notifications
* Voice assistant for guidance
* Health history tracking
* Emergency contact and one-tap doctor call
* Multilingual support (English, Hindi, Kannada)
* Secure cloud sync using Firebase

---

### 🔹 Doctor Web Dashboard

* Live monitoring of multiple patients
* AI-generated alerts (Normal / Warning / Emergency)
* Patient history and trend analysis
* Remote consultation (chat/video)
* Emergency notifications
* AI chatbot for medical insights

---

## 🧠 AI & Data Intelligence

* Real-time data processing and anomaly detection
* Predictive analysis for:

  * Pre-eclampsia
  * Preterm labor
  * Fetal distress
* Personalized risk scoring per patient
* Secure cloud-based data handling

---

## 🚀 Unique Advantages

* Designed specifically for **maternal health**, not general fitness
* Works **outside hospital environments**
* Combines maternal + fetal monitoring in one system
* Suitable for **low-bandwidth and rural regions**
* End-to-end healthcare ecosystem

---

## 🏗️ System Architecture

```
Wearable Sensors → ESP32 → Firebase Cloud
                   ↓
           AI Risk Analysis Engine
                   ↓
   Mobile App ←→ Doctor Web Dashboard
```

---

## 🔮 Future Scope

* Integration with government health schemes (e.g., JSY, NHM)
* Advanced AI models for high-risk pregnancy prediction
* Offline-first functionality with auto-sync
* Postnatal and newborn monitoring
* Hospital & PHC integration
* Population-level maternal health analytics

---

## 🌍 Impact

* Reduced maternal and neonatal mortality
* Early detection of pregnancy complications
* Improved access to healthcare in remote areas
* Data-driven maternal healthcare decisions

---

## 🛠️ Tech Stack (Proposed)

* **Hardware:** ESP32, Biomedical Sensors
* **Frontend:** Flutter / React
* **Backend:** Firebase (Auth, Firestore, Cloud Functions)
* **AI/ML:** Python, TensorFlow / Scikit-learn
* **Database:** Firebase / Cloud Firestore
* **Cloud:** Firebase / GCP

---

# 📱 Mobile App Installation & Usage (APK)

## 📥 How to Install the MatriCare Mobile App (APK)

The MatriCare mobile application is distributed as an **APK file** for easy installation on Android devices.

### 🔹 Step 1: Download the APK

1. Open the GitHub repository or shared download link.
2. Download the file:

   ```
   MatriCare.apk
   ```

---

### 🔹 Step 2: Allow Installation from Unknown Sources

Since this app is not from the Google Play Store:

1. Open **Settings** on your Android phone
2. Go to **Security / Privacy**
3. Enable **Install unknown apps**
4. Allow permission for:

   * Chrome / File Manager / Browser (whichever you used to download)

---

### 🔹 Step 3: Install the App

1. Open the downloaded `MatriCare.apk`
2. Tap **Install**
3. Wait for installation to complete
4. Tap **Open**

---

## 📲 Using the MatriCare App

### 👩‍⚕️ For Pregnant Mothers (User Mode)

Once installed:

1. Open the app
2. Register or log in
3. Connect wearable device (if available)
4. View:

   * Heart rate
   * Fetal movement
   * Risk level (Normal / Warning / Emergency)
5. Receive:

   * Health alerts
   * Notifications
   * Emergency warnings
6. Use emergency call button when required

---

### 🩺 For Doctors (Doctor Mode)

1. Login using doctor credentials
2. View patient list in real-time
3. Monitor vitals and risk levels
4. Access historical health data
5. Receive emergency alerts
6. Provide remote consultation and guidance

---

## 🔌 Backend Connection (Important)

For the app to work correctly:

* Ensure the **Flask backend server** is running:

  ```
  http://<server-ip>:5000
  ```
* The mobile app fetches real-time data from:

  ```
  /api/data
  ```

⚠️ If using locally:

* Mobile device and server must be on the **same Wi-Fi network**
* Replace `localhost` with your system’s IP address (e.g., `192.168.1.5`)

---


## 🔒 Security Notes

* Data transmission secured via API
* User data handled securely
* No personal data stored without consent




