HERE="$(cd "$(dirname "$0")" && pwd)"

cat > "$HERE/.git/hooks/pre-commit" <<'EOF'
#!/usr/bin/env bash

HERE="$(cd "$(dirname "$0")" && pwd)"
ARGS=(hook-impl --config=.pre-commit-config.yaml --hook-type=pre-commit --hook-dir "$HERE" -- "$@")

if command -v docker > /dev/null; then
	docker build -f ./Dockerfile.pre-commit -t pre-commit:latest . > /dev/null 2>&1
	exec docker run \
		--rm \
		-v "$(pwd):/workdir" \
		-v "/tmp:/tmp" \
		-w /workdir \
		--user "$(id -u):$(id -g)" \
		-e HOME='/tmp' \
		pre-commit:latest \
		pre-commit "${ARGS[@]}"
else
    echo '`docker` not found.' 1>&2
    exit 1
fi
EOF

chmod +x "$HERE/.git/hooks/pre-commit"

echo 'pre-commit installed at .git/hooks/pre-commit'
