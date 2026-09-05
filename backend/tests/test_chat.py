from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_chat_with_plant_context():
    payload = {
        "message": "Why is this plant important?",
        "plant_id": 1
    }
    response = client.post("/api/v1/chat", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "reply" in data
    assert len(data["reply"]) > 0
    assert data["plant_id"] == 1
    assert data["plant_name"] == "Banyan Tree"


def test_chat_without_plant_context():
    payload = {
        "message": "What is native flora?"
    }
    response = client.post("/api/v1/chat", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "reply" in data


def test_chat_with_conversation_history():
    payload = {
        "message": "How can I help conserve it?",
        "plant_id": 1,
        "chat_history": [
            {"role": "user", "content": "Tell me about the Banyan tree"},
            {"role": "assistant", "content": "The Banyan is a keystone species in India."}
        ]
    }
    response = client.post("/api/v1/chat", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "reply" in data
    assert len(data["reply"]) > 0

