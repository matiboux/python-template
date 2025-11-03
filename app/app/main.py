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


def create_server(port: int | None = None) -> ThreadingHTTPServer:
	"""Create and return a configured ThreadingHTTPServer instance."""
	if port is None:
		port = int(os.environ.get('PORT', '8080'))
	return ThreadingHTTPServer(('0.0.0.0', port), HelloHandler)


def main() -> None:
	"""Start a threaded HTTP server that responds with 'Hello, world!' to all GET requests."""
	logging.basicConfig(level=logging.INFO)
	logger = logging.getLogger(__name__)
	httpd = create_server()
	port = httpd.server_address[1]
	logger.info("Serving HTTP on 0.0.0.0 port %d (http://0.0.0.0:%d/) ...", port, port)
	logger.info("Open http://localhost:%d locally in your browser.", port)
	httpd.serve_forever()


if __name__ == '__main__':
	main()
