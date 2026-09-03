# Field Intelligence App for Native Plants (AR + AI Assistant)

An augmented reality (AR) and artificial intelligence (AI) biodiversity field assistant application built for the **Godrej Enterprises Group XR Hackathon**.

![Status](https://img.shields.io/badge/status-active_development-emerald)
![Tech](https://img.shields.io/badge/stack-Flutter_%7C_FastAPI_%7C_PostgreSQL_%7C_Gemini-blue)

## Project Overview
The **Field Intelligence App** enables field researchers, students, and eco-tourists across India to scan native flora, identify species using AI, visualize contextual ecological information anchored in 3D AR space, interact with a domain-trained AI Botanical Guide, and explore a curated database of Indian plant species.

## High Level Architecture
```
Flutter Mobile App (iOS / Android)
    │
    │ HTTPS (REST API)
    ▼
FastAPI Backend (Python)
    │
    ├── Pl@ntNet API (Plant Identification Service)
    ├── Gemini API (AI Botanical Guide with RAG context)
    └── PostgreSQL Database (Curated Native Indian Species Catalog)
```

## Key Capabilities
1. **Plant Scanner**: Instant identification powered by Pl@ntNet API with confidence scoring (`High`, `Moderate`, `Low`) and guidance.
2. **AR Spatial Card View**: AR overlay anchoring common name, family, conservation status, and ecological importance in real space.
3. **AI Botanical Guide**: Gemini API chatbot restricted to verifiable plant facts and context to promote native conservation.
4. **Native Plant Catalog**: Searchable native species catalog with rich botanical images, threats, habitat details, and action guides.

## Repository Structure
- `backend/`: FastAPI backend service, schemas, route handlers, pytest suite, and deployment config.
- `flutter_app/`: Flutter mobile application codebase (iOS/Android).

## Quick Start (Backend)
```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

Interactive API documentation available at `http://localhost:8000/docs`.
