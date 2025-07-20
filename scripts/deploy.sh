#!/bin/bash

# Voice Changer Better 部署脚本

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

# 默认配置
DEFAULT_PORT=18888
DEFAULT_MODE="gpu"
DEFAULT_CONTAINER_NAME="voice-changer-better"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -n|--name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -h|--help)
            echo "使用方法: $0 [选项]"
            echo "选项:"
            echo "  -p, --port PORT        设置端口号 (默认: 18888)"
            echo "  -m, --mode MODE        设置模式 gpu|cpu (默认: gpu)"
            echo "  -n, --name NAME        设置容器名称 (默认: voice-changer-better)"
            echo "  -h, --help             显示帮助信息"
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            exit 1
            ;;
    esac
done

# 设置默认值
PORT=${PORT:-$DEFAULT_PORT}
MODE=${MODE:-$DEFAULT_MODE}
CONTAINER_NAME=${CONTAINER_NAME:-$DEFAULT_CONTAINER_NAME}

log_info "部署配置:"
log_info "  端口: ${PORT}"
log_info "  模式: ${MODE}"
log_info "  容器名称: ${CONTAINER_NAME}"

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查docker-compose是否安装
if ! command -v docker-compose &> /dev/null; then
    log_error "docker-compose 未安装，请先安装 docker-compose"
    exit 1
fi

# 检查是否在项目根目录
if [ ! -f "docker-compose.yml" ]; then
    log_error "请在项目根目录运行此脚本"
    exit 1
fi

# 停止现有容器
log_info "停止现有容器..."
docker-compose down || true

# 创建必要的目录
log_info "创建必要的目录..."
mkdir -p models pretrain tmp

# 根据模式启动服务
if [ "$MODE" = "cpu" ]; then
    log_info "启动 CPU 模式..."
    docker-compose --profile cpu up -d voice-changer-cpu
else
    log_info "启动 GPU 模式..."
    docker-compose up -d voice-changer
fi

# 等待服务启动
log_info "等待服务启动..."
sleep 10

# 检查服务状态
log_info "检查服务状态..."
if docker-compose ps | grep -q "Up"; then
    log_success "服务启动成功！"
    log_info "访问地址: http://localhost:${PORT}"
    log_info "查看日志: docker-compose logs -f"
    log_info "停止服务: docker-compose down"
else
    log_error "服务启动失败！"
    log_info "查看错误日志: docker-compose logs"
    exit 1
fi

log_success "部署完成！"