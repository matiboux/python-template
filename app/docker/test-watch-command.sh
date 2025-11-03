#!/bin/sh
set -e

PYTEST_DIR="$HOME/pytest"
PYTEST_CACHE="$PYTEST_DIR/.cache"
COVERAGE_FILE="$PYTEST_DIR/.coverage"
COVERAGE_REPORT="$PYTEST_DIR/cov.json"
TESTMON_DATAFILE="$PYTEST_DIR/.testmondata"

mkdir -p "$PYTEST_DIR"

# Run Pytest using Pytest Watch & Testmon with coverage
COVERAGE_FILE="$COVERAGE_FILE" \
TESTMON_DATAFILE="$TESTMON_DATAFILE" \
pytest-watch --runner pytest -- \
	-vv \
	-o cache_dir="$PYTEST_CACHE" \
	--asyncio-mode auto \
	--testmon \
	--cov \
	--cov-report term-missing:skip-covered \
	--cov-report json:"$COVERAGE_REPORT"
