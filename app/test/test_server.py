
import threading
import time
import httpx
import os
import pytest
from app.main import HelloHandler
from http.server import ThreadingHTTPServer


@pytest.fixture(scope="module", autouse=True)
def start_server():
    port = int(os.environ.get("TEST_PORT", "8081"))
    httpd = ThreadingHTTPServer(("127.0.0.1", port), HelloHandler)
    server_thread = threading.Thread(target=httpd.serve_forever)
    server_thread.start()
    time.sleep(0.5)  # Give server time to start
    yield
    httpd.shutdown()
    server_thread.join()

def test_hello_world():
    port = int(os.environ.get('TEST_PORT', '8081'))
    response = httpx.get(f'http://127.0.0.1:{port}/')
    assert response.status_code == 200
    assert response.text == 'Hello, world!'
