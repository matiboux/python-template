"""Simple HTTP server module that responds with 'Hello, world!' to all GET requests."""

import os
import logging
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class HelloHandler(BaseHTTPRequestHandler):
	def do_GET(self) -> None:
		self.send_response(200)
		self.send_header('Content-type', 'text/plain')
		self.end_headers()
		self.wfile.write(b'Hello, world!')


def main() -> None:
	"""Start a threaded HTTP server that responds with 'Hello, world!' to all GET requests."""
	logging.basicConfig(level=logging.INFO)
	http_port = int(os.getenv('PORT', '8080'))
	httpd = ThreadingHTTPServer(('0.0.0.0', http_port), HelloHandler)
	logging.info(f"Serving HTTP on 0.0.0.0 port {http_port} (http://0.0.0.0:{http_port}/) ...")
	logging.info(f"Open http://localhost:{http_port} locally in your browser.")
	httpd.serve_forever()


if __name__ == '__main__':
	main()
