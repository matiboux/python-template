#!/usr/bin/env python3

"""Healthcheck script for HTTP server container."""

import os
import urllib.request

HTTP_OK = 200

port = os.environ.get('PORT', '8080')
response = urllib.request.urlopen(f"http://localhost:{port}/healthz")

if response.status != HTTP_OK:
	msg = f"Healthcheck failed: status {response.status} != {HTTP_OK}"
	raise RuntimeError(msg)
