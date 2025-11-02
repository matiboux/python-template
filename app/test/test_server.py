import threading
import time
import httpx
import os
import pytest
from app.main import main


@pytest.fixture(scope="module", autouse=True)
def start_server():
    # Set the port for the test
    os.environ["PORT"] = os.getenv("TEST_PORT", "8081")
    server_thread = threading.Thread(target=main, daemon=True)
    server_thread.start()
    time.sleep(0.5)  # Give server time to start
    yield
    # No explicit shutdown since daemon=True

def test_hello_world():
    port = int(os.getenv('TEST_PORT', '8081'))
    response = httpx.get(f'http://127.0.0.1:{port}/')
    assert response.status_code == 200
    assert response.text == 'Hello, world!'
