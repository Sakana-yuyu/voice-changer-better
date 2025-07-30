#!/bin/bash

# Voice Changer Better - Web界面快速启动脚本
# 用于在环境配置完成后直接启动变声界面

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "Voice Changer Better - Web界面快速启动脚本"
    echo
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  --help, -h          显示此帮助信息"
    echo "  --port PORT         指定端口号（默认：6006）"
    echo "  --anaconda          使用Anaconda环境启动"
    echo "  --docker            使用Docker容器启动"
    echo "  --check             仅检查服务状态"
    echo "  --stop              停止正在运行的服务"
    echo
    echo "示例:"
    echo "  $0                  # 自动检测环境并启动"
    echo "  $0 --anaconda       # 使用Anaconda环境启动"
    echo "  $0 --docker         # 使用Docker容器启动"
    echo "  $0 --port 8080      # 使用8080端口启动"
    echo "  $0 --check          # 检查服务状态"
    echo "  $0 --stop           # 停止服务"
    echo
}

# 解析命令行参数
parse_arguments() {
    PORT=6006
    MODE="auto"
    ACTION="start"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --port)
                PORT="$2"
                shift 2
                ;;
            --anaconda)
                MODE="anaconda"
                shift
                ;;
            --docker)
                MODE="docker"
                shift
                ;;
            --check)
                ACTION="check"
                shift
                ;;
            --stop)
                ACTION="stop"
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 检查端口是否被占用
check_port() {
    local port=$1
    if command -v netstat &> /dev/null; then
        if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
            return 0
        fi
    elif command -v ss &> /dev/null; then
        if ss -tlnp 2>/dev/null | grep -q ":$port "; then
            return 0
        fi
    elif command -v lsof &> /dev/null; then
        if lsof -i :$port &> /dev/null; then
            return 0
        fi
    fi
    return 1
}

# 检查服务状态
check_service_status() {
    log_step "检查服务状态..."
    
    if check_port $PORT; then
        log_success "服务正在运行，端口: $PORT"
        log_info "Web界面地址: http://localhost:$PORT"
        
        # 尝试检查API接口
        if command -v curl &> /dev/null; then
            if curl -f http://localhost:$PORT/api/hello &> /dev/null; then
                log_success "API接口响应正常"
            else
                log_warning "端口已占用但API接口无响应"
            fi
        fi
        return 0
    else
        log_info "服务未运行，端口 $PORT 可用"
        return 1
    fi
}

# 停止服务
stop_service() {
    log_step "停止Voice Changer服务..."
    
    # 检查Docker容器
    if command -v docker &> /dev/null && docker ps | grep -q "voice-changer"; then
        log_info "停止Docker容器..."
        docker stop voice-changer 2>/dev/null || true
        log_success "Docker容器已停止"
    fi
    
    # 检查进程
    if command -v pkill &> /dev/null; then
        if pkill -f "MMVCServerSIO.py" 2>/dev/null; then
            log_success "Python进程已停止"
        fi
    fi
    
    # 再次检查端口
    sleep 2
    if check_port $PORT; then
        log_warning "端口 $PORT 仍被占用，可能需要手动停止相关进程"
        if command -v lsof &> /dev/null; then
            log_info "占用端口的进程:"
            lsof -i :$PORT 2>/dev/null || true
        fi
    else
        log_success "服务已完全停止"
    fi
}

# 自动检测环境
detect_environment() {
    log_step "自动检测运行环境..."
    
    # 检查Docker容器是否存在
    if command -v docker &> /dev/null && docker ps -a | grep -q "voice-changer"; then
        log_info "检测到Docker容器"
        return 0  # Docker模式
    fi
    
    # 检查Anaconda环境
    if command -v conda &> /dev/null; then
        if conda env list | grep -q "voice-changer-py310"; then
            log_info "检测到Anaconda环境: voice-changer-py310"
            return 1  # Anaconda模式
        fi
    fi
    
    # 检查Python环境
    if [[ -f "server/MMVCServerSIO.py" ]]; then
        log_info "检测到Python项目文件"
        return 2  # 直接Python模式
    fi
    
    log_error "未检测到可用的运行环境"
    log_info "请先运行部署脚本: ./auto_deploy.sh 或 ./auto_deploy.sh --anaconda"
    return 3  # 无可用环境
}

# 使用Docker启动
start_with_docker() {
    log_step "使用Docker启动服务..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装，请先运行: ./auto_deploy.sh"
        return 1
    fi
    
    # 检查容器是否存在
    if ! docker ps -a | grep -q "voice-changer"; then
        log_error "Docker容器不存在，请先运行: ./auto_deploy.sh"
        return 1
    fi
    
    # 启动容器
    if docker ps | grep -q "voice-changer"; then
        log_info "容器已在运行"
    else
        log_info "启动Docker容器..."
        if docker start voice-changer; then
            log_success "容器启动成功"
        else
            log_error "容器启动失败"
            return 1
        fi
    fi
    
    # 等待服务启动
    wait_for_service
}

# 使用Anaconda启动
start_with_anaconda() {
    log_step "使用Anaconda环境启动服务..."
    
    if ! command -v conda &> /dev/null; then
        log_error "Anaconda未安装，请先运行: ./auto_deploy.sh --anaconda"
        return 1
    fi
    
    # 检查环境是否存在
    if ! conda env list | grep -q "voice-changer-py310"; then
        log_error "voice-changer-py310环境不存在，请先运行: ./auto_deploy.sh --anaconda"
        return 1
    fi
    
    # 使用start_anaconda.sh启动
    if [[ -f "start_anaconda.sh" ]]; then
        log_info "使用start_anaconda.sh启动服务..."
        chmod +x start_anaconda.sh
        ./start_anaconda.sh
    else
        log_error "start_anaconda.sh文件不存在"
        return 1
    fi
}

# 使用Python直接启动
start_with_python() {
    log_step "使用Python直接启动服务..."
    
    if [[ ! -f "server/MMVCServerSIO.py" ]]; then
        log_error "未找到server/MMVCServerSIO.py文件"
        return 1
    fi
    
    # 检查Python和依赖
    if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
        log_error "Python未安装"
        return 1
    fi
    
    # 进入服务器目录
    cd server
    
    # 检查依赖
    if [[ -f "requirements.txt" ]]; then
        log_info "检查Python依赖..."
        python -c "import sys; import pkg_resources; pkg_resources.require(open('requirements.txt').read().splitlines())" 2>/dev/null || {
            log_warning "依赖可能不完整，建议运行: pip install -r requirements.txt"
        }
    fi
    
    # 启动服务
    log_info "启动Voice Changer服务..."
    log_info "服务将在 http://localhost:$PORT 启动"
    log_info "按 Ctrl+C 停止服务"
    echo
    
    # 设置端口环境变量（如果支持）
    export PORT=$PORT
    
    # 启动服务
    python MMVCServerSIO.py
}

# 等待服务启动
wait_for_service() {
    log_step "等待服务启动..."
    
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if check_port $PORT; then
            log_success "服务启动成功！"
            log_info "Web界面地址: http://localhost:$PORT"
            return 0
        fi
        
        log_info "等待服务启动... ($attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    log_error "服务启动超时"
    return 1
}

# 主函数
main() {
    # 解析命令行参数
    parse_arguments "$@"
    
    echo "======================================"
    echo "Voice Changer Better - Web界面启动"
    echo "======================================"
    echo
    
    # 根据动作执行不同操作
    case $ACTION in
        "check")
            check_service_status
            exit $?
            ;;
        "stop")
            stop_service
            exit 0
            ;;
        "start")
            # 继续执行启动逻辑
            ;;
    esac
    
    # 检查端口是否已被占用
    if check_port $PORT; then
        log_warning "端口 $PORT 已被占用"
        log_info "Web界面地址: http://localhost:$PORT"
        log_info "如需重启服务，请先运行: $0 --stop"
        exit 0
    fi
    
    # 根据模式启动服务
    case $MODE in
        "docker")
            start_with_docker
            ;;
        "anaconda")
            start_with_anaconda
            ;;
        "auto")
            detect_environment
            case $? in
                0)
                    start_with_docker
                    ;;
                1)
                    start_with_anaconda
                    ;;
                2)
                    start_with_python
                    ;;
                3)
                    exit 1
                    ;;
            esac
            ;;
    esac
}

# 错误处理
trap 'log_error "脚本执行失败"; exit 1' ERR

# 运行主函数
main "$@"