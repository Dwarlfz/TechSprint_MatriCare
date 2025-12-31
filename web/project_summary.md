# MatriCare Project Summary

## Overview
MatriCare is a real-time maternal health monitoring dashboard designed for doctors. It visualizes patient data, tracks risks, and manages alerts using a modern, responsive interface.

## Technology Stack

### Frontend (Client-Side)
-   **Core**: HTML5, JavaScript (ES6+).
-   **Framework**: React 18 (via CDN with Babel Standalone) - No build step required (no Webpack/Vite).
-   **Styling**: TailwindCSS (via CDN) for rapid, responsive UI design.
-   **Visualization**: Chart.js for real-time medical charts.
-   **Icons**: FontAwesome.

### Backend (Server-Side)
-   **Language**: Python 3.x.
-   **Framework**: Flask (Lightweight web server).
-   **Data Processing**: Pandas (for CSV manipulation).
-   **CORS**: Flask-CORS (to allow the frontend to talk to the backend).

### Data Source
-   **File**: `maternal_training_data.csv`.
-   **Format**: CSV containing maternal health metrics (Heart Rate, BP, Fetal Movement, etc.).

---

## System Architecture & Data Flow

1.  **Data Source**: The system relies on `maternal_training_data.csv` as the "live" database.
2.  **Backend API (`server.py`)**:
    -   Runs on `http://localhost:5000`.
    -   Exposes an endpoint: `GET /api/data`.
    -   Reads the CSV file using Pandas, processes it (calculates averages, risk levels), and returns JSON.
3.  **Frontend Application (`dashboard.html` + `js/dashboard.js`)**:
    -   Runs in the browser.
    -   **Polling**: Every 5 seconds, it sends a request to the Python backend.
    -   **Rendering**: React updates the UI (Charts, Stats, Patient Lists) instantly with the new data.

## Key Features

-   **Real-time Monitoring**: Charts and stats update automatically when the CSV file changes.
-   **Doctor Authentication**: Simple login system (`login.html`) to protect patient data.
-   **Risk Analysis**: Automatically categorizes patients as High/Low risk based on CSV labels.
-   **Interactive Alerts**: Doctors can mark alerts as critical, acknowledge them, or assign tasks.
-   **Doctor Profile & Notes**:
    -   Doctors can save personal notes for specific patients.
    -   Notes are persisted in the browser's `sessionStorage`.
    -   Dedicated "Doctor Profile" view to see all tasks and saved notes.
-   **Modern UI/UX**: "MatriCare" branding with glassmorphism effects, smooth animations, and a notification system.

## How to Run

1.  **Start Backend**:
    ```bash
    cd Doctor
    python server.py
    ```
2.  **Start Frontend**:
    -   Simply open `Doctor/dashboard.html` in any modern web browser.
