#!/bin/bash

# Voice Changer Better 启动脚本
# 在6006端口启动变声界面

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 设置环境变量
export LOCAL_UID=${LOCAL_UID:-1000}
export LOCAL_GID=${LOCAL_GID:-1000}
export EX_PORT=6006
export EX_IP="0.0.0.0"

log_info "Voice Changer Better 正在启动..."
log_info "端口: 6006"
log_info "用户ID: $LOCAL_UID"
log_info "组ID: $LOCAL_GID"

# 创建用户
USER_ID=${LOCAL_UID:-1000}
GROUP_ID=${LOCAL_GID:-1000}

log_info "创建用户 [UID: $USER_ID, GID: $GROUP_ID]"
useradd -u $USER_ID -o -m user || true
groupmod -g $GROUP_ID user || true

# 设置权限
chown -R user:user /voice-changer/server/model_dir || true
chown -R user:user /voice-changer/server/tmp_dir || true
chown -R user:user /resources || true

# 进入服务器目录
cd /voice-changer/server

# 复制资源文件
if [ -d "/resources" ]; then
    log_info "复制资源文件..."
    find /resources/ -type f -name "*.pth" 2>/dev/null | xargs -I{} sh -c 'echo "复制 `basename {}`..." && cp {} ./' || true
    find /resources/ -type f -name "*.onnx" 2>/dev/null | xargs -I{} sh -c 'echo "复制 `basename {}`..." && cp {} ./' || true
fi

# 启动服务
log_info "启动 Voice Changer 服务..."
log_success "服务将在 http://0.0.0.0:6006 启动"
log_success "请在浏览器中访问: http://localhost:6006"

# 检查是否安装了gosu
if command -v gosu >/dev/null 2>&1; then
    log_info "使用gosu切换用户启动服务"
    exec gosu user python3 MMVCServerSIO.py -p 6006 --host 0.0.0.0 --https false
else
    # 如果没有gosu，需要先安装
    log_info "安装gosu..."
    apt-get update && apt-get install -y gosu
    log_info "使用gosu切换用户启动服务"
    exec gosu user python3 MMVCServerSIO.py -p 6006 --host 0.0.0.0 --https false
fi