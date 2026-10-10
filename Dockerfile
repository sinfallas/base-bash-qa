ARG UBUNTU_VERSION=26.04
FROM ubuntu:${UBUNTU_VERSION}
LABEL org.opencontainers.image.authors="sinfallas@gmail.com"
LABEL description="Entorno de QA automatizado para Bash"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get -y dist-upgrade && apt-get -y install --no-install-recommends --no-install-suggests bats shellcheck kcov curl wget git nano jq ca-certificates tzdata && apt clean && apt -y autoremove && rm -rf /var/lib/{apt,dpkg,cache,log} && rm -rf /var/cache/* && rm -rf /var/log/apt/* && rm -rf /tmp/*
RUN LATEST_SHFMT=$(curl -s https://api.github.com/repos/mvdan/sh/releases/latest | jq -r .tag_name) && echo "Instalando shfmt version: $LATEST_SHFMT" && curl -sSLo /usr/local/bin/shfmt "https://github.com/mvdan/sh/releases/download/${LATEST_SHFMT}/shfmt_${LATEST_SHFMT}_linux_amd64" && chmod +x /usr/local/bin/shfmt

RUN mkdir -p /opt/bats-libs && \
    # Función para extraer el último tag de Git sin descargar todo el repositorio
    get_latest_tag() { git ls-remote --tags --refs --sort="v:refname" "$1" | tail -n1 | sed 's/.*\///'; } && \
    \
    SUPPORT_TAG=$(get_latest_tag "https://github.com/bats-core/bats-support.git") && \
    echo "bats-support tag: $SUPPORT_TAG" && \
    git clone --depth 1 --branch "$SUPPORT_TAG" https://github.com/bats-core/bats-support.git /opt/bats-libs/bats-support && \
    \
    ASSERT_TAG=$(get_latest_tag "https://github.com/bats-core/bats-assert.git") && \
    echo "bats-assert tag: $ASSERT_TAG" && \
    git clone --depth 1 --branch "$ASSERT_TAG" https://github.com/bats-core/bats-assert.git /opt/bats-libs/bats-assert && \
    \
    FILE_TAG=$(get_latest_tag "https://github.com/bats-core/bats-file.git") && \
    echo "bats-file tag: $FILE_TAG" && \
    git clone --depth 1 --branch "$FILE_TAG" https://github.com/bats-core/bats-file.git /opt/bats-libs/bats-file && \
    \
    git clone --depth 1 https://github.com/grayhemp/bats-mock.git /opt/bats-libs/bats-mock && \
    rm -rf /opt/bats-libs/*/.git

WORKDIR /app
CMD ["bats", "test/"]
ARG BUILD_DATE
LABEL org.opencontainers.image.created=$BUILD_DATE
