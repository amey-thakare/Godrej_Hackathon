import io
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_identify_valid_image():
    fake_image_bytes = b"\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x01\x00`\x00`\x00\x00"
    files = {"image": ("test_plant.jpg", io.BytesIO(fake_image_bytes), "image/jpeg")}
    response = client.post("/api/v1/identify", files=files)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "identification" in data
    assert len(data["identification"]["scientific_name"]) > 0
    assert data["identification"]["confidence"] >= 0.50


def test_identify_invalid_file_type():
    fake_text_bytes = b"Hello world text file"
    files = {"image": ("test.txt", io.BytesIO(fake_text_bytes), "text/plain")}
    response = client.post("/api/v1/identify", files=files)
    assert response.status_code == 400
    assert "Invalid image format" in response.json()["detail"]


def test_identify_empty_file():
    files = {"image": ("empty.jpg", io.BytesIO(b""), "image/jpeg")}
    response = client.post("/api/v1/identify", files=files)
    assert response.status_code == 400
    assert "empty" in response.json()["detail"]
