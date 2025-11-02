
import threading
import time
import httpx
import os
from http.server import ThreadingHTTPServer
from app.main import HelloHandler

def run_server(port):
    httpd = ThreadingHTTPServer(('127.0.0.1', port), HelloHandler)
    httpd.serve_forever()

def test_hello_world():
    port = int(os.getenv('TEST_PORT', '8081'))
    server_thread = threading.Thread(target=run_server, args=(port,), daemon=True)
    server_thread.start()
    time.sleep(0.5)  # Give server time to start
    response = httpx.get(f'http://127.0.0.1:{port}/')
    assert response.status_code == 200
    assert response.text == 'Hello, world!'
    # No explicit shutdown since daemon=True
