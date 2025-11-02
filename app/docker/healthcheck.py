#!/usr/bin/env python3

import os
import urllib.request

port = os.environ.get('PORT', '8080')
response = urllib.request.urlopen(f"http://localhost:{port}/healthz")

assert response.status == 200
