FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# --- 基础工具（解压用，几乎不变动）---
RUN apt-get -o Acquire::Retries=10 -o Acquire::http::Timeout=60 update \
    && apt-get -o Acquire::Retries=10 -o Acquire::http::Timeout=60 install -y --no-install-recommends \
        ca-certificates unzip \
    && rm -rf /var/lib/apt/lists/*

# --- 仓颉 SDK ---
COPY sdk/cangjie-sdk-linux-x64-1.1.3.tar.gz /tmp/cangjie-sdk.tar.gz
RUN tar -xzf /tmp/cangjie-sdk.tar.gz -C /opt && rm /tmp/cangjie-sdk.tar.gz

# --- stdx 扩展库 ---
COPY sdk/cangjie-stdx-linux-x64-1.1.3.1.zip /tmp/stdx.zip
RUN unzip -q /tmp/stdx.zip -d /opt/stdx && rm /tmp/stdx.zip

# --- 编译所需依赖 ---
#   binutils -> ld
#   libc6-dev -> crti.o / Scrt1.o / crtn.o
#   gcc      -> crtbeginS.o / crtendS.o（glibc 与 libgcc 的启动/收尾目标文件）
RUN apt-get -o Acquire::Retries=10 -o Acquire::http::Timeout=60 update \
    && apt-get -o Acquire::Retries=10 -o Acquire::http::Timeout=60 install -y --no-install-recommends \
        binutils gcc git libc6-dev libssl3 zlib1g libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# 与 SDK 自带 envsetup.sh 保持一致
ENV CANGJIE_HOME=/opt/cangjie
ENV CANGJIE_STDX_PATH=/opt/stdx/linux_x86_64_cjnative/dynamic/stdx
ENV PATH=/opt/cangjie/bin:/opt/cangjie/tools/bin:/root/.cjpm/bin:$PATH
# 注意末尾的 stdx 动态库目录：运行时需要加载 libstdx.*.so
ENV LD_LIBRARY_PATH=/opt/cangjie/runtime/lib/linux_x86_64_cjnative:/opt/cangjie/tools/lib:/opt/stdx/linux_x86_64_cjnative/dynamic/stdx

WORKDIR /app

CMD ["bash"]
