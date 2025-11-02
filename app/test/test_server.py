
import threading
import time
import httpx
import os
import pytest
from app.main import create_server

TEST_PORT = int(os.environ.get('TEST_PORT', '8081'))


@pytest.fixture(scope="module", autouse=True)
def start_server():
    # Set the port for the test
    httpd = create_server(TEST_PORT)
    server_thread = threading.Thread(target=httpd.serve_forever)
    server_thread.start()
    time.sleep(0.5)  # Give server time to start
    yield
    httpd.shutdown()
    server_thread.join()

def test_hello_world():
    response = httpx.get(f'http://127.0.0.1:{TEST_PORT}/')
    assert response.status_code == 200
    assert response.text == 'Hello, world!'
