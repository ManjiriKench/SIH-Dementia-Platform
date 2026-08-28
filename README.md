\# 🧠 Dementia Assist — SIH 2026



AI-powered cognitive assistance platform for elderly dementia patients, focusing on cognitive games, adaptive difficulty, caregiver support, reminders, multilingual/voice interaction and remote-area accessibility.



\## Tech Stack



\- Mobile: Flutter + Dart

\- Backend: Python + Flask

\- AI/ML: Python

\- Database: To be finalized

\- Testing: Android Studio Emulator

\- Version Control: Git + GitHub



\## Project Structure



SIH-Dementia-Platform/

│

├── mobile/       → Flutter mobile application

├── backend/      → Flask backend/API

├── ai/           → AI/ML modules

├── database/     → Database design \& implementation

└── research/     → Research \& evidence



\---



\# Setup



\## 1. Clone Repository



git clone https://github.com/ManjiriKench/SIH-Dementia-Platform.git



cd SIH-Dementia-Platform



\---



\# Flutter / UI-UX Team



Required:

\- Flutter

\- Dart

\- Android Studio

\- Android Emulator

\- VS Code



Run:



cd mobile

flutter pub get

flutter devices

flutter run -d emulator-5554



Flutter code is mainly inside:



mobile/lib/



You do NOT need Python/Flask setup if you are only working on UI/UX.



\---



\# Backend Team



Required:

\- Python 3.12+

\- VS Code

\- Git



Run:



cd backend

python -m venv venv

.\\venv\\Scripts\\Activate.ps1

pip install -r requirements.txt

python app.py



Backend runs on:



http://127.0.0.1:5000



When Flutter Android Emulator connects to the local backend, use:



http://10.0.2.2:5000



\---



\# AI/ML Team



Required:

\- Python 3.12+

\- VS Code

\- Git



AI/ML team can work independently without Flutter/Android Studio.



AI/ML will handle:

\- Game performance analysis

\- Accuracy/response-time analysis

\- Adaptive difficulty

\- Cognitive performance trends

\- AI-based recommendations



AI/ML code will be maintained inside:



ai/



Coordinate with Backend before integrating AI/ML APIs.



\---



\# Database Team



Flutter/Android Studio is NOT required for database development.



Database team will design and implement storage for:



\- Patients

\- Caregivers

\- Games

\- Game sessions

\- Performance data

\- Cognitive metrics

\- Reminders

\- Medicines

\- Appointments

\- Alerts

\- User preferences



Database structure must be coordinated with Backend and AI/ML.



\---



\# Research Team



No technical setup is required.



Research focuses on:

\- Dementia and caregiver problems

\- Existing solutions

\- Cognitive games

\- Elderly usability

\- Multilingual/voice requirements

\- Offline/remote-area requirements

\- Clinical/expert insights

\- Interviews and evidence



Research findings must be connected to actual project features and decisions.



\---



\# 🌿 TEAM GIT WORKFLOW



Everyone works on a SEPARATE BRANCH.



\### Flutter/UI-UX



git checkout -b feature/flutter-ui



\### Backend



git checkout -b feature/backend



\### AI/ML



git checkout -b feature/ai-ml



\### Database



git checkout -b feature/database



\### Research



git checkout -b feature/research



Use your own branch for all work.



Before starting:



git checkout main

git pull origin main

git checkout -b feature/your-name



After completing work:



git add .

git commit -m "Describe your change"

git push -u origin feature/your-branch



Then inform the team lead.



\## IMPORTANT



Do NOT directly push to `main`.



Branches will be reviewed and merged into `main`.



Before modifying another teammate's files, coordinate with them first.



\---



\# Project Architecture



Flutter App

&#x20;     ↓

&#x20;  REST API

&#x20;     ↓

Flask Backend

&#x20;  ↓       ↓

Database   AI/ML

&#x20;  ↑       ↓

&#x20;  └───────┘



Example:



Game completed

→ Flutter sends result

→ Backend receives it

→ Database stores performance

→ AI/ML analyses performance

→ Difficulty recommendation generated

→ Flutter receives next difficulty



\---



\# Security



Never commit:



\- `.env`

\- API keys

\- passwords

\- credentials

\- patient personal information

\- `venv/`

\- build/generated files



The `.gitignore` already excludes the main sensitive/generated files.



\---



\# Current Status



Completed:

\- Flutter project setup

\- Android Emulator connection

\- Flask backend setup

\- Flutter/backend service structure

\- GitHub repository



Currently developing:

\- UI/UX

\- Cognitive games

\- Backend APIs

\- AI/ML

\- Database

\- Research

\- Caregiver features

\- Adaptive difficulty

\- Multilingual/voice features



\## Final Rule



Every feature must either:



1\. satisfy the SIH problem statement,

2\. solve a validated patient/caregiver problem, or

3\. provide a meaningful innovation.



Do not add features only because they look technically impressive.

