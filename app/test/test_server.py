"""Tests for the HTTP server."""

import os
import threading
import time
from typing import TYPE_CHECKING

if TYPE_CHECKING:
	from collections.abc import Iterator

import httpx
import pytest

from app.main import create_server

TEST_PORT = int(os.environ.get('TEST_PORT', '8081'))
HTTP_OK = 200


@pytest.fixture(scope="module", autouse=True)
def start_server() -> Iterator[None]:
	"""Pytest fixture to start and stop the HTTP server for tests."""
	httpd = create_server(TEST_PORT)
	server_thread = threading.Thread(target=httpd.serve_forever)
	server_thread.start()
	time.sleep(0.5)  # Give server time to start
	yield
	httpd.shutdown()
	server_thread.join()


def test_hello_world() -> None:
	"""Test that the HTTP server responds with 'Hello, world!' and status 200."""
	response = httpx.get(f'http://127.0.0.1:{TEST_PORT}/')
	if response.status_code != HTTP_OK:
		msg = f"Expected status {HTTP_OK}, got {response.status_code}"
		raise AssertionError(msg)
	if response.text != 'Hello, world!':
		msg = f"Expected body 'Hello, world!', got {response.text!r}"
		raise AssertionError(msg)
