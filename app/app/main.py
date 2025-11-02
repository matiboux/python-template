"""Simple HTTP server module that responds with 'Hello, world!' to all GET requests."""

import logging
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class HelloHandler(BaseHTTPRequestHandler):
	"""Request handler that responds with 'Hello, world!' to all GET requests."""

	def do_GET(self) -> None:
		"""Handle GET requests by responding with 'Hello, world!'."""
		self.send_response(200)
		self.send_header('Content-type', 'text/plain')
		self.end_headers()
		self.wfile.write(b'Hello, world!')


def main() -> None:
	"""Start a threaded HTTP server that responds with 'Hello, world!' to all GET requests."""
	logging.basicConfig(level=logging.INFO)
	logger = logging.getLogger(__name__)
	http_port = int(os.getenv('PORT', '8080'))
	httpd = ThreadingHTTPServer(('0.0.0.0', http_port), HelloHandler)
	logger.info(
		"Serving HTTP on 0.0.0.0 port %d (http://0.0.0.0:%d/) ...", http_port, http_port
	)
	logger.info("Open http://localhost:%d locally in your browser.", http_port)
	httpd.serve_forever()


if __name__ == '__main__':
	main()
