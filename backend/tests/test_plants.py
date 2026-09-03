from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_get_plants_catalog():
    response = client.get("/api/v1/plants")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0
    assert "scientific_name" in data[0]
    assert "common_name" in data[0]


def test_get_plants_with_search():
    response = client.get("/api/v1/plants?q=Banyan")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1
    assert data[0]["common_name"] == "Banyan Tree"


def test_get_plant_by_id_success():
    response = client.get("/api/v1/plants/1")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == 1
    assert data["common_name"] == "Banyan Tree"


def test_get_plant_by_id_not_found():
    response = client.get("/api/v1/plants/999999")
    assert response.status_code == 404
    assert "not found" in response.json()["detail"]
