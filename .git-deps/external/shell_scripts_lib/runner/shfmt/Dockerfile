#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#           GLOBALS
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
ARG HOME="/usr/runner"
ARG BINARY_HOME="${HOME}/.local/bin"
ARG RUNNER_WORKSPACE="${HOME}/workspace"
ARG RUNNER_ENTRYPOINT="runner_dockerized_entrypoint"
# OS/Architecture: darwin_amd64, darwin_arm64, linux_amd64, linux_arm, linux_arm64
ARG RUNNER_OS_ARCH="linux_amd64"

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#         SHFMT BUILDER
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Downgrade to Alpine 3.12.x due to issue with Raspberry Pi ARM issue
# See: https://github.com/gliderlabs/docker-alpine/issues/386#issuecomment-1000644809
FROM alpine:3.12.9 AS shfmt-builder
LABEL maintainer="Zachi Nachshon <zachi.nachshon@gmail.com>"

# Can be overridden
ENV RUNNER_CLI_NAME="shfmt"
ARG RUNNER_VERSION

# Use globals
ARG BINARY_HOME
ARG RUNNER_OS_ARCH

# Add in here how the binary should be installed
RUN apk update && apk add --virtual .build-dependencies --no-cache bash openssl curl openssh-server \
    && mkdir -p ${BINARY_HOME} \
    && cd /tmp \
    && wget -O ${RUNNER_CLI_NAME} "https://github.com/mvdan/sh/releases/download/v${RUNNER_VERSION}/shfmt_v${RUNNER_VERSION}_${RUNNER_OS_ARCH}" \
    && mv ./${RUNNER_CLI_NAME} ${BINARY_HOME} \
    && chmod +x ${BINARY_HOME}/${RUNNER_CLI_NAME} \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

ENV PATH=${BINARY_HOME}:$PATH

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#         SHFMT RUNNER
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
FROM shfmt-builder AS shfmt-runner
LABEL maintainer="Zachi Nachshon <zachi.nachshon@gmail.com>"

# Use globals
ARG RUNNER_WORKSPACE
ARG RUNNER_ENTRYPOINT

ENV RUNNER_ARGS=""
ENV DEBUG=""

COPY ${RUNNER_ENTRYPOINT}.sh /usr/local/bin/${RUNNER_ENTRYPOINT}

RUN chmod +x /usr/local/bin/${RUNNER_ENTRYPOINT} \
    && mkdir -p ${RUNNER_WORKSPACE}

WORKDIR ${RUNNER_WORKSPACE}

ENTRYPOINT ["runner_dockerized_entrypoint"]
