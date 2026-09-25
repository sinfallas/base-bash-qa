FROM ubuntu:26.04
LABEL org.opencontainers.image.authors="sinfallas@gmail.com"
LABEL description="Entorno de QA corporativo para Bash: ShellCheck, BATS, kcov y shfmt"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get -y dist-upgrade && apt-get -y install --no-install-recommends --no-install-suggests \
    bats shellcheck kcov curl wget git nano jq ca-certificates tzdata && \
    apt clean && apt -y autoremove && rm -rf /var/lib/{apt,dpkg,cache,log} && rm -rf /var/cache/* && rm -rf /var/log/apt/* && rm -rf /tmp/*

RUN curl -sSLo /usr/local/bin/shfmt https://github.com/mvdan/sh/releases/download/v3.8.0/shfmt_v3.8.0_linux_amd64 && chmod +x /usr/local/bin/shfmt

RUN mkdir -p /opt/bats-libs && \
    git clone --depth 1 https://github.com/bats-core/bats-support.git /opt/bats-libs/bats-support && \
    git clone --depth 1 https://github.com/bats-core/bats-assert.git /opt/bats-libs/bats-assert && \
    git clone --depth 1 https://github.com/bats-core/bats-file.git /opt/bats-libs/bats-file && \
    git clone --depth 1 https://github.com/grayhemp/bats-mock.git /opt/bats-libs/bats-mock && \
    rm -rf /opt/bats-libs/*/.git

WORKDIR /app

CMD ["bash", "-c", "echo 'Contenedor QA Bash listo.'; sleep infinity"]
ARG BUILD_DATE
LABEL org.opencontainers.image.created=$BUILD_DATE
