#syntax=docker/dockerfile:1

# This Dockerfile uses the root folder as context.


# --
# Upstream images

FROM alpine:3.19 AS alpine_upstream
FROM docker:25.0 AS docker_upstream


# --
# Scan fs image

FROM alpine_upstream AS app_scan_fs

# Set app directory
WORKDIR /app

# Set shell
SHELL [ "/bin/ash", "-o", "pipefail", "-c" ]

# Set runtime environment
ENV APP_ENV=test

# Install Trivy
# (see Trivy releases: https://github.com/aquasecurity/trivy/releases)
# (hadolint: Ignore non-pinned apk package version, because repository updates discard previous versions)
# hadolint ignore=DL3018
RUN --mount=type=cache,id=apk,target=/var/cache/apk \
	apk add curl && \
	curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
		| sh -s -- -b /usr/local/bin v0.67.2

# Mount source code as volume
VOLUME /app

CMD [ "trivy", "-q", "fs", "--exit-code", "1", "/app" ]


# --
# Scan docker image

FROM docker_upstream AS app_scan_docker

# Set app directory
WORKDIR /app

# Set shell
SHELL [ "/bin/ash", "-o", "pipefail", "-c" ]

# Set runtime environment
ENV APP_ENV=test

# Install Trivy
# (see Trivy releases: https://github.com/aquasecurity/trivy/releases)
# (hadolint: Ignore non-pinned apk package version, because repository updates discard previous versions)
# hadolint ignore=DL3018
RUN --mount=type=cache,id=apk,target=/var/cache/apk \
	apk add curl && \
	curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
		| sh -s -- -b /usr/local/bin v0.67.2

# Mount source code as volume
VOLUME /app

# Runtime environment variables
ARG DOCKER_COMPOSE_FILES=''
ENV DOCKER_COMPOSE_FILES=${DOCKER_COMPOSE_FILES}
ARG DOCKER_COMPOSE_SERVICE='app'
ENV DOCKER_COMPOSE_SERVICE=${DOCKER_COMPOSE_SERVICE}

CMD [ "sh", "-c", "docker compose $DOCKER_COMPOSE_FILES build \"$DOCKER_COMPOSE_SERVICE\" && trivy -q image --exit-code 1 $(docker compose $DOCKER_COMPOSE_FILES images \"$DOCKER_COMPOSE_SERVICE\" -q)" ]
