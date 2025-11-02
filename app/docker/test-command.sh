#!/bin/sh
set -e

PYTEST_DIR="$HOME/pytest"
PYTEST_CACHE="$PYTEST_DIR/.cache"
COVERAGE_FILE="$PYTEST_DIR/.coverage"
COVERAGE_REPORT="$PYTEST_DIR/cov.json"

mkdir -p "$PYTEST_DIR"

# Run Pytest with coverage
COVERAGE_FILE="$COVERAGE_FILE" \
pytest \
	-vv \
	-o cache_dir="$PYTEST_CACHE" \
	--asyncio-mode auto \
	--cov \
	--cov-report term-missing:skip-covered \
	--cov-report json:"$COVERAGE_REPORT"

if [ ! -f "$COVERAGE_REPORT" ]; then
	echo "No Pytest coverage report found" >&2 # stderr
	exit 0
fi

# Get Pytest coverage score
COVERAGE="$(jq '.totals.percent_covered' < "$COVERAGE_REPORT")"

if [ -z "$COVERAGE" ]; then
	echo "No Pytest coverage score reported" >&2 # stderr
	exit 0
fi

# Set COVERAGE_THRESHOLD if not set
if [ -z "$COVERAGE_THRESHOLD" ]; then
	COVERAGE_THRESHOLD='50'
fi

# Fail if coverage is below threshold
FAILED=$(awk "BEGIN {print ($COVERAGE < $COVERAGE_THRESHOLD)}")
if [ "$FAILED" = "1" ]; then
	COVERAGE_DISPLAY=$(jq -r '.totals.percent_covered_display' < "$COVERAGE_REPORT")
	echo "Coverage of $COVERAGE_DISPLAY% is below threshold of $COVERAGE_THRESHOLD%" >&2 # stderr
	exit 1
fi
