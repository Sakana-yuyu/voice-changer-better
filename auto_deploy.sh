#!/bin/bash

# Voice Changer Better 自动化部署脚本
# 从Docker安装到服务启动的完整自动化流程
# 适用于Ubuntu/Debian系统

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

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "检测到root用户，建议使用普通用户运行此脚本"
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 检测操作系统
detect_os() {
    log_step "检测操作系统..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        log_info "检测到系统: $OS $VER"
    else
        log_error "无法检测操作系统"
        exit 1
    fi
    
    # 检查是否为支持的系统
    case $OS in
        "Ubuntu"*)
            PACKAGE_MANAGER="apt"
            ;;
        "Debian"*)
            PACKAGE_MANAGER="apt"
            ;;
        "CentOS"*|"Red Hat"*|"Rocky"*|"AlmaLinux"*)
            PACKAGE_MANAGER="yum"
            log_warning "检测到CentOS/RHEL系统，部分命令可能需要调整"
            ;;
        *)
            log_warning "未完全测试的系统: $OS"
            ;;
    esac
}

# 更新系统
update_system() {
    log_step "更新系统包..."
    
    case $PACKAGE_MANAGER in
        "apt")
            sudo apt update && sudo apt upgrade -y
            ;;
        "yum")
            sudo yum update -y
            ;;
    esac
    
    log_success "系统更新完成"
}

# 安装基础依赖
install_dependencies() {
    log_step "安装基础依赖..."
    
    case $PACKAGE_MANAGER in
        "apt")
            sudo apt install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                lsb-release \
                git \
                wget \
                unzip
            ;;
        "yum")
            sudo yum install -y \
                yum-utils \
                device-mapper-persistent-data \
                lvm2 \
                curl \
                git \
                wget \
                unzip
            ;;
    esac
    
    log_success "基础依赖安装完成"
}

# 检查Docker是否已安装
check_docker() {
    log_step "检查Docker安装状态..."
    
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        log_info "Docker已安装，版本: $DOCKER_VERSION"
        
        # 检查Docker服务状态
        if systemctl is-active --quiet docker 2>/dev/null; then
            log_success "Docker服务正在运行"
            return 0
        elif service docker status &> /dev/null; then
            log_success "Docker服务正在运行"
            return 0
        else
            log_warning "Docker已安装但服务未运行，尝试启动..."
            start_docker_service
            return 0
        fi
    else
        log_info "Docker未安装，开始安装..."
        return 1
    fi
}

# 安装Docker
install_docker() {
    log_step "安装Docker..."
    
    case $PACKAGE_MANAGER in
        "apt")
            # 添加Docker官方GPG密钥
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            
            # 添加Docker仓库
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # 更新包索引
            sudo apt update
            
            # 安装Docker Engine
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        "yum")
            # 添加Docker仓库
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            
            # 安装Docker Engine
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
    esac
    
    log_success "Docker安装完成"
}

# 启动Docker服务
start_docker_service() {
    log_step "启动Docker服务..."
    
    # 尝试使用systemctl启动
    if command -v systemctl &> /dev/null; then
        sudo systemctl start docker
        sudo systemctl enable docker
        log_success "Docker服务已启动并设置为开机自启"
    # 尝试使用service启动
    elif command -v service &> /dev/null; then
        sudo service docker start
        log_success "Docker服务已启动"
    # 手动启动Docker守护进程
    else
        log_warning "无法使用systemctl或service，尝试手动启动Docker守护进程..."
        sudo dockerd --host=unix:///var/run/docker.sock --iptables=false --storage-driver=vfs &
        sleep 5
        log_success "Docker守护进程已启动"
    fi
}

# 配置Docker用户权限
setup_docker_permissions() {
    log_step "配置Docker用户权限..."
    
    # 将当前用户添加到docker组
    sudo usermod -aG docker $USER
    
    log_success "用户权限配置完成"
    log_warning "请注意：需要重新登录或运行 'newgrp docker' 使权限生效"
}

# 验证Docker安装
verify_docker() {
    log_step "验证Docker安装..."
    
    # 检查Docker版本
    if docker --version &> /dev/null; then
        DOCKER_VERSION=$(docker --version)
        log_info "$DOCKER_VERSION"
    else
        log_error "Docker版本检查失败"
        return 1
    fi
    
    # 运行hello-world测试
    if sudo docker run --rm hello-world &> /dev/null; then
        log_success "Docker安装验证成功"
    else
        log_error "Docker hello-world测试失败"
        return 1
    fi
}

# 安装NVIDIA Docker（可选）
install_nvidia_docker() {
    log_step "检查是否需要安装NVIDIA Docker..."
    
    # 检查是否有NVIDIA GPU
    if command -v nvidia-smi &> /dev/null; then
        log_info "检测到NVIDIA GPU，安装NVIDIA Docker支持..."
        
        case $PACKAGE_MANAGER in
            "apt")
                # 添加NVIDIA Docker仓库
                distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
                curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
                curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
                
                sudo apt update
                sudo apt install -y nvidia-docker2
                ;;
            "yum")
                distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
                curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo
                
                sudo yum install -y nvidia-docker2
                ;;
        esac
        
        # 重启Docker服务
        sudo systemctl restart docker || sudo service docker restart
        
        log_success "NVIDIA Docker安装完成"
    else
        log_info "未检测到NVIDIA GPU，跳过NVIDIA Docker安装"
    fi
}

# 准备项目目录
prepare_project() {
    log_step "准备项目目录..."
    
    # 创建必要的目录
    mkdir -p docker_folder/model_dir
    mkdir -p docker_folder/pretrain
    
    # 设置目录权限
    chmod 755 docker_folder
    chmod 755 docker_folder/model_dir
    chmod 755 docker_folder/pretrain
    
    log_success "项目目录准备完成"
    log_info "模型目录: $(pwd)/docker_folder/model_dir"
    log_info "预训练模型目录: $(pwd)/docker_folder/pretrain"
}

# 构建Docker镜像
build_docker_image() {
    log_step "构建Voice Changer Better Docker镜像..."
    
    # 检查Dockerfile是否存在
    if [[ ! -f "Dockerfile" ]]; then
        log_error "Dockerfile不存在，请确保在项目根目录运行此脚本"
        exit 1
    fi
    
    # 构建镜像
    log_info "开始构建镜像，这可能需要几分钟时间..."
    
    if sudo docker build -t voice-changer-better . ; then
        log_success "Docker镜像构建完成"
    else
        log_error "Docker镜像构建失败"
        exit 1
    fi
}

# 运行容器
run_container() {
    log_step "启动Voice Changer Better容器..."
    
    # 停止并删除已存在的容器
    if sudo docker ps -a | grep -q "voice-changer"; then
        log_info "停止并删除已存在的容器..."
        sudo docker stop voice-changer 2>/dev/null || true
        sudo docker rm voice-changer 2>/dev/null || true
    fi
    
    # 检查是否支持GPU
    if command -v nvidia-smi &> /dev/null && sudo docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi &> /dev/null; then
        log_info "启动GPU版本容器..."
        sudo docker run -d \
            --name voice-changer \
            --gpus all \
            -p 6006:6006 \
            -v "$(pwd)/docker_folder/model_dir:/voice-changer/server/model_dir" \
            -v "$(pwd)/docker_folder/pretrain:/resources" \
            -e LOCAL_UID=$(id -u) \
            -e LOCAL_GID=$(id -g) \
            voice-changer-better
    else
        log_info "启动CPU版本容器..."
        sudo docker run -d \
            --name voice-changer \
            -p 6006:6006 \
            -v "$(pwd)/docker_folder/model_dir:/voice-changer/server/model_dir" \
            -v "$(pwd)/docker_folder/pretrain:/resources" \
            -e LOCAL_UID=$(id -u) \
            -e LOCAL_GID=$(id -g) \
            voice-changer-better
    fi
    
    log_success "容器启动完成"
}

# 等待服务启动
wait_for_service() {
    log_step "等待服务启动..."
    
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -f http://localhost:6006/api/hello &> /dev/null; then
            log_success "服务启动成功！"
            return 0
        fi
        
        log_info "等待服务启动... ($attempt/$max_attempts)"
        sleep 5
        ((attempt++))
    done
    
    log_error "服务启动超时"
    return 1
}

# 验证部署
verify_deployment() {
    log_step "验证部署状态..."
    
    # 检查容器状态
    if sudo docker ps | grep -q "voice-changer"; then
        log_success "容器运行正常"
    else
        log_error "容器未运行"
        sudo docker logs voice-changer
        return 1
    fi
    
    # 检查API接口
    if curl -f http://localhost:6006/api/hello &> /dev/null; then
        log_success "API接口响应正常"
    else
        log_error "API接口无响应"
        return 1
    fi
    
    # 显示访问信息
    log_success "部署验证完成！"
    echo
    log_info "访问信息:"
    log_info "  Web界面: http://localhost:6006"
    log_info "  API接口: http://localhost:6006/api/hello"
    echo
    log_info "管理命令:"
    log_info "  查看日志: sudo docker logs voice-changer"
    log_info "  停止服务: sudo docker stop voice-changer"
    log_info "  启动服务: sudo docker start voice-changer"
    log_info "  重启服务: sudo docker restart voice-changer"
}

# 显示使用说明
show_usage() {
    echo
    log_info "使用说明:"
    echo "  1. 将模型文件(.pth)放入: $(pwd)/docker_folder/model_dir/"
    echo "  2. 将预训练模型(.onnx)放入: $(pwd)/docker_folder/pretrain/"
    echo "  3. 在浏览器中访问: http://localhost:6006"
    echo "  4. 上传或选择模型开始使用"
    echo
}

# 主函数
main() {
    echo "======================================"
    echo "Voice Changer Better 自动化部署脚本"
    echo "======================================"
    echo
    
    # 检查root用户
    check_root
    
    # 检测操作系统
    detect_os
    
    # 更新系统
    update_system
    
    # 安装基础依赖
    install_dependencies
    
    # 检查并安装Docker
    if ! check_docker; then
        install_docker
        start_docker_service
        setup_docker_permissions
        verify_docker
    fi
    
    # 安装NVIDIA Docker（如果需要）
    install_nvidia_docker
    
    # 准备项目
    prepare_project
    
    # 构建镜像
    build_docker_image
    
    # 运行容器
    run_container
    
    # 等待服务启动
    wait_for_service
    
    # 验证部署
    verify_deployment
    
    # 显示使用说明
    show_usage
    
    echo
    log_success "🎉 Voice Changer Better 部署完成！"
    echo
}

# 错误处理
trap 'log_error "脚本执行失败，请检查错误信息"; exit 1' ERR

# 运行主函数
main "$@"