#!/bin/bash

# Voice Changer Better Docker 构建脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数定义
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

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查是否在项目根目录
if [ ! -f "Dockerfile" ]; then
    log_error "请在项目根目录运行此脚本"
    exit 1
fi

# 获取版本号
VERSION=$(date +%Y%m%d_%H%M%S)
IMAGE_NAME="voice-changer-better"
FULL_IMAGE_NAME="${IMAGE_NAME}:${VERSION}"
LATEST_IMAGE_NAME="${IMAGE_NAME}:latest"

log_info "开始构建 Docker 镜像..."
log_info "镜像名称: ${FULL_IMAGE_NAME}"

# 构建镜像
log_info "正在构建镜像，这可能需要几分钟时间..."
if docker build -t "${FULL_IMAGE_NAME}" -t "${LATEST_IMAGE_NAME}" .; then
    log_success "镜像构建成功！"
    log_info "镜像标签: ${FULL_IMAGE_NAME}"
    log_info "镜像标签: ${LATEST_IMAGE_NAME}"
else
    log_error "镜像构建失败！"
    exit 1
fi

# 显示镜像信息
log_info "镜像信息:"
docker images | grep "${IMAGE_NAME}"

# 询问是否运行容器
read -p "是否立即运行容器？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "启动容器..."
    docker run -d \
        --name voice-changer-better-test \
        -p 18888:18888 \
        --gpus all \
        "${LATEST_IMAGE_NAME}"
    
    log_success "容器已启动！"
    log_info "访问地址: http://localhost:18888"
    log_info "查看日志: docker logs voice-changer-better-test"
    log_info "停止容器: docker stop voice-changer-better-test"
fi

log_success "构建完成！"