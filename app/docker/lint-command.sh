#!/bin/sh
set -e

RUFF_DIR="$HOME/ruff"
RUFF_CACHE_DIR="$RUFF_DIR/.cache"
RUFF_LOGFILE="$RUFF_DIR/ruff.log"
RUFF_JSONFILE="$RUFF_DIR/ruff.json"

mkdir -p "$RUFF_DIR"
mkdir -p "$RUFF_CACHE_DIR"

export RUFF_CACHE_DIR

# Run Ruff on project files
# Output to stdout in a human-readable format & Save to the log file
ruff check .. | tee "$RUFF_LOGFILE"

if [ ! -f "$RUFF_LOGFILE" ]; then
	echo '' >&2
	echo "Failed to find Ruff log file" >&2
	exit 1
fi

# Count data in Ruff report
LIST_REPORTS="$(grep -E '^\s+-->\s+.+:[0-9]+:[0-9]+\s*$' "$RUFF_LOGFILE" | sed -E 's/^\s+-->\s+(.+):[0-9]+:[0-9]+\s*$/\1/' | sort)"

if [ -z "$LIST_REPORTS" ]; then
	exit 0
fi

# Count data in Ruff report
NB_REPORTS="$(echo "$LIST_REPORTS" | wc -l)"
NB_REPORTED_FILES="$(echo "$LIST_REPORTS" | uniq | wc -l)"

# Count Python files in the project
NB_TOTAL_FILES="$(find .. -type f -name "*.py" | wc -l)"

# Output summary
echo ''
echo 'Summary of Ruff linting:'
echo " - Number of Python files: $NB_TOTAL_FILES"
echo " - Number of files with violations: $NB_REPORTED_FILES"
echo " - Number of violations: $NB_REPORTS"

# Compute percentage of files with violations
# Use reports instead of reported files to add weight to files with multiple violations
SCORE="$(
	awk \
	-v total="$NB_TOTAL_FILES" \
	-v reports="$NB_REPORTS" \
	'BEGIN {
		if (total == 0) {
			print "0.00"
		} else {
			printf "%.2f", ((total - reports) / total) * 100
		}
	}'
)"

# Output score
echo ''
echo "Lint score: $SCORE %"

# Set SCORE_THRESHOLD if not set
if [ -z "$SCORE_THRESHOLD" ]; then
	SCORE_THRESHOLD='50'
fi

# Fail if score is below threshold
FAILED=$(
	awk \
	-v score="$SCORE" \
	-v threshold="$SCORE_THRESHOLD" \
	'BEGIN {
		print (score < threshold) ? 1 : 0
	}'
)

if [ "$FAILED" = "1" ]; then
	echo '' >&2
	echo "Lint score is below threshold of $SCORE_THRESHOLD %" >&2
	exit 1
fi

echo '' >&2
echo "Lint score is above threshold of $SCORE_THRESHOLD %" >&2
exit 0
