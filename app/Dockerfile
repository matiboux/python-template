#syntax=docker/dockerfile:1

# This Dockerfile uses the service folder as context.


# --
# Global build arguments

ARG UID=1001


# --
# Upstream images

# (see uv releases: https://github.com/astral-sh/uv/releases)

FROM python:3.14-slim AS python_upstream
FROM ghcr.io/astral-sh/uv:0.9 AS python_uv_upstream


# --
# Base image

FROM python_upstream AS python_base

# Set app directory
WORKDIR /workdir/app
ENV PYTHONPATH=/workdir

# Set home directory for cache
ENV HOME=/tmp

# Set venv configuration
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
ENV VIRTUAL_ENV="$UV_PROJECT_ENVIRONMENT"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"


# --
# Build base image

FROM python_base AS python_build_base

# Install uv (package manager)
COPY --from=python_uv_upstream --link --chmod=755 /uv /uvx /usr/local/bin/

# Install build dependencies
# (hadolint: Ignore non-pinned apt package version)
# hadolint ignore=DL3008
RUN --mount=type=cache,sharing=locked,id=apt-cache,target=/var/cache/apt \
	--mount=type=cache,sharing=locked,id=apt-lib,target=/var/lib/apt \
	apt-get update && \
	apt-get install -y --no-install-recommends build-essential


# --
# Install base image

FROM python_build_base AS deps_base

# Copy build configuration
COPY --link ./app/pyproject.toml ./app/uv.lock ./


# --
# Install dev base image

FROM deps_base AS deps_dev

# Install dev Python dependencies
# (hadolint: Ignore pip cache usage, because cache is stored in a mount point)
# hadolint ignore=DL3042
RUN --mount=type=cache,id=uv,target=/tmp/uv-cache \
	export UV_CACHE_DIR=/tmp/uv-cache && \
	export UV_LINK_MODE=copy && \
	uv sync --frozen


# --
# Install prod base image

FROM deps_base AS deps_prod

# Install prod Python dependencies
# (hadolint: Ignore pip cache usage, because cache is stored in a mount point)
# hadolint ignore=DL3042
RUN --mount=type=cache,id=uv,target=/tmp/uv-cache \
	export UV_CACHE_DIR=/tmp/uv-cache && \
	export UV_LINK_MODE=copy && \
	uv sync --frozen --no-dev


# --
# CLI image

FROM python_build_base AS app_cli

# Build arguments
ARG UID

# Set uv configuration
ENV UV_LINK_MODE=copy

# Create command aliases (pip)
COPY --link --chmod=755 ./docker/pip-cli-alias.sh /usr/local/bin/aliases/pip

# Install sudo
# (hadolint: Ignore non-pinned apt package version)
# hadolint ignore=DL3008
RUN --mount=type=cache,sharing=locked,id=apt-cache,target=/var/cache/apt \
	--mount=type=cache,sharing=locked,id=apt-lib,target=/var/lib/apt \
	apt-get update && \
	apt-get install -y --no-install-recommends sudo && \
	echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Create user 'user' in group 'root' & 'sudo'
# (hadolint: Ignore unchecked pipe failures)
# hadolint ignore=DL4006
RUN USERNAME="$(getent passwd "${UID}" 2>/dev/null | cut -d: -f1 || true)"; \
	if [ -z "${USERNAME}" ]; then \
		useradd -lm -u "${UID}" -U -G 0,sudo user; \
	else \
		usermod -a -G 0,sudo "${USERNAME}"; \
	fi

# Run as created non-root user
USER ${UID}

# Mount source code & virtual environment as volumes
VOLUME /workdir/app
VOLUME /opt/venv

# Run CLI command
COPY --link --chmod=755 ./docker/cli-entrypoint.sh /usr/local/bin/app-cli-entrypoint
ENTRYPOINT [ "app-cli-entrypoint" ]
CMD [ "--help" ]


# --
# Lint image

FROM python_base AS app_lint

# Build arguments
ARG UID

# Set runtime environment
ENV APP_ENV=test

# Copy lint virtual environment
COPY --from=deps_dev --link --chmod=755 /opt/venv /opt/venv

# Copy source code
RUN chown "${UID}:0" .
COPY --link --chown="${UID}:0" ./app/ ./
COPY --link --chown="${UID}:0" ./docker ../docker
COPY --link --chown="${UID}:0" ./test ../test

# Run as non-root user
USER ${UID}:0

COPY --link --chmod=755 ./docker/lint-command.sh /usr/local/bin/app-lint-command
CMD [ "app-lint-command" ]


# --
# Python jq base image

FROM python_base AS python_jq_base

# Install jq
# (hadolint: Ignore non-pinned apt package version)
# hadolint ignore=DL3008
RUN --mount=type=cache,sharing=locked,id=apt-cache,target=/var/cache/apt \
	--mount=type=cache,sharing=locked,id=apt-lib,target=/var/lib/apt \
	apt-get update && \
	apt-get install -y --no-install-recommends jq


# --
# Test base image

FROM python_jq_base AS app_test_base

# Build arguments
ARG UID

# Set runtime environment
ENV APP_ENV=test

# Copy test virtual environment
COPY --from=deps_dev --link --chmod=755 /opt/venv /opt/venv

# Copy data & source code
RUN chown "${UID}:0" .
COPY --link --chown="${UID}:0" ./app/ ./
COPY --link --chown="${UID}:0" ./test ./test


# --
# Test image

FROM app_test_base AS app_test

# Build arguments
ARG UID

# Run as non-root user
USER ${UID}:0

# Mount data as volume
VOLUME /data

COPY --link --chmod=755 ./docker/test-command.sh /usr/local/bin/app-test-command
CMD [ "app-test-command" ]


# --
# Test watch image

FROM app_test_base AS app_test_watch

# Build arguments
ARG UID

# Copy test-watch virtual environment
COPY --from=deps_dev --link --chmod=755 /opt/venv /opt/venv

# Create user 'user' in group 'root'
# (hadolint: Ignore unchecked pipe failures)
# hadolint ignore=DL4006
RUN USERNAME="$(getent passwd "${UID}" 2>/dev/null | cut -d: -f1 || true)"; \
	if [ -z "${USERNAME}" ]; then \
		useradd -lm -u "${UID}" -U -G 0 user; \
	else \
		usermod -a -G 0 "${USERNAME}"; \
	fi

# Run as created non-root user
USER ${UID}

# Mount data as volume
VOLUME /data

COPY --link --chmod=755 ./docker/test-watch-command.sh /usr/local/bin/app-test-watch-command
CMD [ "app-test-watch-command" ]


# --
# Dev image

FROM python_base AS app_dev

# Build arguments
ARG UID

# Set runtime environment
ENV APP_ENV=dev

# Copy virtual environment
COPY --from=deps_dev --link --chmod=755 /opt/venv /opt/venv

# Copy source code
RUN chown "${UID}:0" .
COPY --link --chown="${UID}:0" ./app/ ./

# Create user 'user' in group 'root'
# (hadolint: Ignore unchecked pipe failures)
# hadolint ignore=DL4006
RUN USERNAME="$(getent passwd "${UID}" 2>/dev/null | cut -d: -f1 || true)"; \
	if [ -z "${USERNAME}" ]; then \
		useradd -lm -u "${UID}" -U -G 0 user; \
	else \
		usermod -a -G 0 "${USERNAME}"; \
	fi

# Run as created non-root user
USER ${UID}

# Set exposed port
ARG PORT=8080
ENV PORT=${PORT}
EXPOSE ${PORT}

# Healthcheck script
COPY --link --chmod=755 ./docker/healthcheck.py /usr/local/bin/app-healthcheck

CMD [ "sh", "-c", "python main.py" ]


# --
# Prod image

FROM python_base AS app_prod

# Build arguments
ARG UID

# Set runtime environment
ENV APP_ENV=prod

# Copy virtual environment
COPY --from=deps_prod --link --chmod=755 /opt/venv /opt/venv

# Copy source code
COPY --link --chown="${UID}:0" ./app/ ./

# Run as non-root user
USER ${UID}:0

# Set exposed port
ARG PORT=8080
ENV PORT=${PORT}
EXPOSE ${PORT}

# Healthcheck script
COPY --link --chmod=755 ./docker/healthcheck.py /usr/local/bin/app-healthcheck

CMD [ "sh", "-c", "python main.py" ]
