def main():
    import os
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class HelloHandler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Hello, world!')

    http_port = int(os.getenv('PORT', '8080'))
    httpd = HTTPServer(('0.0.0.0', http_port), HelloHandler)
    print(f"Serving HTTP on 0.0.0.0 port {http_port} (http://0.0.0.0:{http_port}/) ...")
    print(f"Open http://localhost:{http_port} locally in your browser.")
    httpd.serve_forever()


if __name__ == "__main__":
    main()
