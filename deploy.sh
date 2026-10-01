#!/usr/bin/env bash
# =============================================================================
# 畅溪鸿蒙APP 后端 — 云服务器一键部署脚本
#
# 在目标服务器（Ubuntu 22.04 x86_64）上运行一次，即可完成：
#   1. 安装仓颉工具链（cjc / cjpm / 运行时，版本 1.1.3）
#   2. 安装仓颉标准库扩展 stdx（1.1.3.1，与工具链匹配）
#   3. 克隆天擎框架 spire（gitcode.com/soulsoft/spire）
#   4. 拉取本项目（github 公开仓库）
#   5. 写入并持久化环境变量（env.sh + ~/.bashrc）
#   6. 构建（cjpm build），并打印手动运行方式
#
# 用法：  ./deploy.sh
# 前置：  本机已把源码 push 到 GitHub（当前 main 上的文件尚未提交，记得先 push）
# 幂等：  重复执行安全，已装好的依赖会跳过
# =============================================================================
set -euo pipefail

# ------------------------- 可配置项（可用环境变量覆盖） -------------------------
DEV_DIR="${DEV_DIR:-$HOME/developer}"          # 工具链/框架/stdx 的安装根目录
APP_DIR="${APP_DIR:-$HOME/changxi-backend}"    # 本项目目录
PROJECT_REPO="https://github.com/yaojiwww/changxi-backend.git"
SPIRE_REPO="https://gitcode.com/soulsoft/spire"

# 仓颉工具链（编译器 + cjpm + 运行时）
CANGJIE_VER="1.1.3"
CANGJIE_SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-${CANGJIE_VER}.tar.gz&objectKey=6a19349d21f5a8178d6fd22b"
CANGJIE_SDK_SHA256="2b68905afc466e665ae181595c63f96c18d75fd2c1fb6c6f0cb64e179c28d61a"

# 仓颉标准库扩展 stdx（版本号跟随工具链 1.1.3 → 1.1.3.1）
STDX_VER="1.1.3.1"
STDX_URL="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v${STDX_VER}/cangjie-stdx-linux-x64-${STDX_VER}.zip"

# ------------------------- 内部变量（勿改） -------------------------
ARCH="$(uname -m)"
RUNTIME_ARCH="linux_${ARCH}_cjnative"                     # 例：linux_x86_64_cjnative
CANGJIE_HOME="$DEV_DIR/cangjie"                           # 工具链目录
STDX_DIR="$DEV_DIR/stdx"                                  # stdx 根目录
CANGJIE_STDX_PATH="$STDX_DIR/$RUNTIME_ARCH/dynamic/stdx"  # stdx 动态库目录
SPIRE_PATH="$DEV_DIR/spire/"                              # 末尾 / 必须保留（cjpm.toml 里是 ${SPIRE_PATH}xxx）
ENV_FILE="$DEV_DIR/env.sh"                                # 生成的环境变量脚本

# ------------------------- 输出辅助 -------------------------
c_info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
c_ok()    { printf '\033[1;32m[ OK ]\033[0m %s\n' "$*"; }
c_warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
c_err()   { printf '\033[1;31m[FAIL]\033[0m %s\n' "$*" >&2; }

# ------------------------- 1. 检查架构与基础依赖 -------------------------
c_info "目标架构: $ARCH"
if [ "$ARCH" != "x86_64" ]; then
    c_err "本脚本只准备了 x86_64 的下载地址与校验和，当前是 $ARCH，请改用对应版本。"
    exit 1
fi

MISSING=()
for cmd in git curl unzip tar sha256sum; do
    command -v "$cmd" >/dev/null 2>&1 || MISSING+=("$cmd")
done
if [ "${#MISSING[@]}" -gt 0 ]; then
    c_warn "缺少基础工具: ${MISSING[*]}，尝试用 apt 安装..."
    sudo apt-get update -y
    sudo apt-get install -y "${MISSING[@]}"
fi
c_ok "基础依赖就绪"

mkdir -p "$DEV_DIR" "$STDX_DIR"

# ------------------------- 2. 安装仓颉工具链 -------------------------
if [ -x "$CANGJIE_HOME/bin/cjc" ]; then
    c_ok "仓颉工具链已存在，跳过（$CANGJIE_HOME）"
else
    c_info "下载仓颉工具链 SDK ${CANGJIE_VER}（约 400MB，请耐心等待）..."
    SDK_TAR="$(mktemp -t cangjie-sdk.XXXXXX)"
    curl -fsSL --retry 3 -o "$SDK_TAR" "$CANGJIE_SDK_URL"

    c_info "校验 SHA256..."
    echo "$CANGJIE_SDK_SHA256  $SDK_TAR" | sha256sum -c - >/dev/null

    c_info "解压并安装到 $CANGJIE_HOME ..."
    TMP_DIR="$(mktemp -d)"
    tar -xzf "$SDK_TAR" -C "$TMP_DIR"
    TOP_DIR="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    [ -n "$TOP_DIR" ] || { c_err "解压后未找到工具链目录"; exit 1; }
    mv "$TOP_DIR" "$CANGJIE_HOME"
    rm -rf "$TMP_DIR" "$SDK_TAR"
    c_ok "仓颉工具链安装完成"
fi

# ------------------------- 3. 安装 stdx -------------------------
if [ -d "$CANGJIE_STDX_PATH" ]; then
    c_ok "stdx 已存在，跳过（$CANGJIE_STDX_PATH）"
else
    c_info "下载 stdx ${STDX_VER}（约 20MB）..."
    STDX_ZIP="$(mktemp -t cangjie-stdx.XXXXXX)"
    curl -fsSL --retry 3 -o "$STDX_ZIP" "$STDX_URL"

    c_info "解压到 $STDX_DIR ..."
    unzip -q "$STDX_ZIP" -d "$STDX_DIR"
    rm -f "$STDX_ZIP"
    [ -d "$CANGJIE_STDX_PATH" ] || { c_err "stdx 解压后未找到 $CANGJIE_STDX_PATH"; exit 1; }
    c_ok "stdx 安装完成"
fi

# ------------------------- 4. 克隆天擎框架 spire -------------------------
if [ -d "$SPIRE_PATH" ]; then
    c_ok "spire 已存在，跳过（$SPIRE_PATH）"
else
    c_info "克隆天擎框架 spire ..."
    git clone --depth 1 "$SPIRE_REPO" "$DEV_DIR/spire"
    c_ok "spire 克隆完成"
fi

# ------------------------- 5. 拉取本项目 -------------------------
if [ -d "$APP_DIR/.git" ]; then
    c_info "项目已存在，执行 git pull ..."
    git -C "$APP_DIR" pull --ff-only
else
    c_info "克隆项目 ..."
    git clone "$PROJECT_REPO" "$APP_DIR"
fi
c_ok "项目就绪（$APP_DIR）"

# ------------------------- 6. 生成环境变量脚本 env.sh -------------------------
c_info "生成环境变量脚本 $ENV_FILE ..."
cat > "$ENV_FILE" <<EOF
# 由 deploy.sh 生成，重复执行会覆盖。source 本文件即可加载全部环境。
export CANGJIE_HOME="$CANGJIE_HOME"
export SPIRE_PATH="$SPIRE_PATH"
export CANGJIE_STDX_PATH="$CANGJIE_STDX_PATH"
export PATH="$CANGJIE_HOME/bin:$CANGJIE_HOME/tools/bin:\$PATH:\$HOME/.cjpm/bin"
export LD_LIBRARY_PATH="$CANGJIE_HOME/runtime/lib/$RUNTIME_ARCH:$CANGJIE_HOME/tools/lib:\${LD_LIBRARY_PATH:-}"
EOF

# 追加到 ~/.bashrc（幂等），让每次登录自动生效
ENV_LINE="[ -f \"$ENV_FILE\" ] && source \"$ENV_FILE\""
if ! grep -qF "$ENV_FILE" "$HOME/.bashrc" 2>/dev/null; then
    echo "$ENV_LINE" >> "$HOME/.bashrc"
    c_ok "已写入 ~/.bashrc（下次登录自动生效）"
else
    c_info "~/.bashrc 已包含 env.sh，跳过"
fi

# ------------------------- 7. 构建 -------------------------
c_info "开始构建（cjpm build）..."
# shellcheck disable=SC1090
source "$ENV_FILE"
cd "$APP_DIR"
cjpm build
c_ok "构建完成"

# ------------------------- 8. 汇总 -------------------------
cat <<EOF

============================================================
 部署完成！
============================================================
 项目目录:   $APP_DIR
 工具链:     $CANGJIE_HOME
 stdx:       $CANGJIE_STDX_PATH
 spire:      $SPIRE_PATH
 环境变量:   $ENV_FILE（已写入 ~/.bashrc）

 手动运行（监听 0.0.0.0:8080）:
   source $ENV_FILE
   cd $APP_DIR
   ./target/release/bin/main

 健康检查:
   curl http://127.0.0.1:8080/hello
============================================================
EOF
c_ok "全部完成"
