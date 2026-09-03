# Native Plants Field Intelligence Backend API

FastAPI backend service powering the AR + AI Assistant for India's Native Flora.

## API Features & Endpoints
- `GET /health`: Health check endpoint for Railway deployment and uptime monitoring.
- `GET /api/v1/plants`: Retrieve list of curated native Indian plant profiles with search capabilities.
- `GET /api/v1/plants/{id}`: Detailed plant information (ecological, habitat, conservation, identification).
- `POST /api/v1/identify`: Secure Pl@ntNet species identification from uploaded plant photos.
- `POST /api/v1/chat`: Gemini-powered AI Botanical Guide chatbot with database RAG context.

## Local Setup & Development

### 1. Environment Setup
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

### 3. Run FastAPI Development Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Swagger UI will be available at: [http://localhost:8000/docs](http://localhost:8000/docs)

### 4. Run Pytest Suite
```bash
pytest tests/
```

## Railway Deployment
This repository contains `Dockerfile` and `health` endpoint configuration ready for deployment on Railway.
Ensure `PLANTNET_API_KEY`, `GEMINI_API_KEY`, and `DATABASE_URL` environment variables are set in your Railway project.
