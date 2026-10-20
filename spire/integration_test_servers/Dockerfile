FROM debian:12-slim

ARG APT_MIRROR=mirrors.tuna.tsinghua.edu.cn

ENV DEBIAN_FRONTEND=noninteractive
ENV CANGJIE_HOME=/opt/cangjie
ENV CANGJIE_STDX_PATH=/opt/cangjie/stdx/linux_x86_64_cjnative/static/stdx
ENV PATH=/opt/cangjie/bin:/opt/cangjie/tools/bin:/root/.cjpm/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/cangjie/runtime/lib/linux_x86_64_cjnative:/opt/cangjie/tools/lib:${LD_LIBRARY_PATH}

RUN set -eux; \
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
        sed -i "s|http://deb.debian.org/debian|http://${APT_MIRROR}/debian|g; s|http://security.debian.org/debian-security|http://${APT_MIRROR}/debian-security|g" /etc/apt/sources.list.d/debian.sources; \
    fi; \
    if [ -f /etc/apt/sources.list ]; then \
        sed -i "s|http://deb.debian.org/debian|http://${APT_MIRROR}/debian|g; s|http://security.debian.org/debian-security|http://${APT_MIRROR}/debian-security|g" /etc/apt/sources.list; \
    fi; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        binutils \
        build-essential \
        ca-certificates \
        curl \
        git \
        libc++-dev \
        python3 \
        python3-pytest \
        python3-requests \
        libpython3.11 \
        libssl3 \
        unzip \
    && ln -sf /usr/bin/python3 /usr/local/bin/python \
    && rm -rf /var/lib/apt/lists/*

COPY runtime/cangjie-sdk-linux-x64-1.1.3.tar.gz /tmp/sdk.tar.gz
COPY runtime/cangjie-stdx-linux-x64-1.1.3.1.zip /tmp/stdx.zip

RUN tar -xzf /tmp/sdk.tar.gz -C /opt \
    && mkdir -p /opt/cangjie/stdx \
    && unzip -q /tmp/stdx.zip -d /opt/cangjie/stdx \
    && rm -f /tmp/sdk.tar.gz /tmp/stdx.zip

WORKDIR /workspace

CMD ["/bin/bash"]
