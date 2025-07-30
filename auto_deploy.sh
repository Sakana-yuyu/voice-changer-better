#!/bin/bash

# Voice Changer Better 自动化部署脚本
# 从Docker安装到服务启动的完整自动化流程
# 适用于Ubuntu/Debian系统

set -e

# 全局变量初始化
INIT_SYSTEM="unknown"
IN_CONTAINER="false"
IS_ROOT="false"
SKIP_DOCKER_INSTALL="false"
PACKAGE_MANAGER=""

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

# 检查并安装sudo
check_and_install_sudo() {
    if [[ $EUID -eq 0 ]]; then
        # 检查sudo是否存在
        if ! command -v sudo &> /dev/null; then
            log_warning "检测到sudo命令不存在"
            read -p "是否安装sudo？(y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_step "安装sudo..."
                case $PACKAGE_MANAGER in
                    "apt")
                        apt update && apt install -y sudo
                        ;;
                    "yum")
                        yum install -y sudo
                        ;;
                esac
                log_success "sudo安装完成"
            else
                log_warning "选择不安装sudo，将以root权限直接执行命令"
                # 创建一个临时脚本，去除所有sudo命令
                log_step "创建无sudo版本的脚本..."
                sed 's/sudo //g' "$0" > "${0%.sh}_root.sh"
                chmod +x "${0%.sh}_root.sh"
                log_info "已创建 ${0%.sh}_root.sh，请运行此脚本"
                exit 0
            fi
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

# 检测系统环境和初始化系统
detect_system_environment() {
    log_step "检测系统环境..."
    
    # 检测初始化系统
    if [ -d "/run/systemd/system" ] && command -v systemctl &> /dev/null; then
        INIT_SYSTEM="systemd"
        log_info "检测到systemd初始化系统"
    elif [ -f "/sbin/init" ] && [ -d "/etc/init.d" ]; then
        INIT_SYSTEM="sysv"
        log_info "检测到SysV初始化系统"
    else
        INIT_SYSTEM="unknown"
        log_warning "未知的初始化系统，将使用手动启动方式"
    fi
    
    # 检测是否在容器环境中
    if [ -f "/.dockerenv" ] || grep -q "docker\|lxc" /proc/1/cgroup 2>/dev/null; then
        IN_CONTAINER="true"
        log_warning "检测到容器环境，某些功能可能受限"
    else
        IN_CONTAINER="false"
        log_info "运行在宿主机环境"
    fi
    
    # 检测权限
    if [ "$EUID" -eq 0 ]; then
        IS_ROOT="true"
        log_info "当前用户为root"
    else
        IS_ROOT="false"
        log_info "当前用户为普通用户"
    fi
    
    # 输出环境信息
    log_info "系统环境信息:"
    log_info "  初始化系统: $INIT_SYSTEM"
    log_info "  容器环境: $IN_CONTAINER"
    log_info "  Root权限: $IS_ROOT"
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
        
        # 检查Docker服务状态（多种方式检测）
        if docker info &> /dev/null; then
            log_success "Docker服务正在运行"
            return 0
        elif systemctl is-active --quiet docker 2>/dev/null; then
            log_success "Docker服务正在运行（systemctl检测）"
            return 0
        elif service docker status &> /dev/null 2>&1; then
            log_success "Docker服务正在运行（service检测）"
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
            # 优先尝试使用国内镜像源
            log_info "使用阿里云镜像源安装Docker..."
            
            # 添加Docker GPG密钥（使用阿里云镜像）
            if curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; then
                log_success "GPG密钥添加成功"
            else
                log_warning "阿里云镜像源失败，尝试清华大学镜像源..."
                curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            fi
            
            # 添加Docker仓库（使用阿里云镜像）
            if echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; then
                log_success "阿里云Docker仓库添加成功"
            else
                log_warning "阿里云仓库添加失败，使用清华大学镜像源..."
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            fi
            
            # 更新包索引
            sudo apt update
            
            # 安装Docker Engine
            if ! sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
                log_warning "使用镜像源安装失败，尝试使用Ubuntu官方仓库..."
                sudo apt install -y docker.io
            fi
            ;;
        "yum")
            # 优先尝试使用国内镜像源
            log_info "使用阿里云镜像源安装Docker..."
            
            # 添加Docker仓库（使用阿里云镜像）
            if sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo; then
                log_success "阿里云Docker仓库添加成功"
            else
                log_warning "阿里云镜像源失败，使用官方源..."
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            fi
            
            # 安装Docker Engine
            if ! sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
                log_warning "使用镜像源安装失败，尝试使用系统默认仓库..."
                sudo yum install -y docker
            fi
            ;;
    esac
    
    log_success "Docker安装完成"
}

# 启动Docker服务
start_docker_service() {
    log_step "启动Docker服务..."
    
    # 检查Docker守护进程是否已经在运行
    if docker info &> /dev/null; then
        log_success "Docker守护进程已在运行"
        return 0
    fi
    
    # 根据初始化系统选择启动方式
    case "$INIT_SYSTEM" in
        "systemd")
            log_info "使用systemctl启动Docker服务..."
            if sudo systemctl start docker 2>/dev/null; then
                sudo systemctl enable docker 2>/dev/null
                log_success "Docker服务已启动并设置为开机自启"
                return 0
            else
                log_warning "systemctl启动失败，尝试其他方式"
            fi
            ;;
        "sysv")
            log_info "使用service启动Docker服务..."
            # 修复可能的ulimit问题
            if [ -f "/etc/init.d/docker" ]; then
                # 备份原文件
                sudo cp /etc/init.d/docker /etc/init.d/docker.backup 2>/dev/null || true
                # 注释掉可能有问题的ulimit行
                sudo sed -i 's/^[[:space:]]*ulimit/#&/' /etc/init.d/docker 2>/dev/null || true
            fi
            
            if sudo service docker start 2>/dev/null; then
                log_success "Docker服务已启动"
                return 0
            else
                log_warning "service启动失败，尝试手动启动"
            fi
            ;;
        *)
            log_info "未知初始化系统，直接尝试手动启动"
            ;;
    esac
    
    # 手动启动Docker守护进程（适用于容器环境或特殊情况）
    log_warning "尝试手动启动Docker守护进程..."
    
    # 在容器环境中，通常不需要停止现有进程
    if [ "$IN_CONTAINER" != "true" ]; then
        # 停止可能存在的Docker进程
        sudo pkill dockerd 2>/dev/null || true
        sudo pkill docker-containerd 2>/dev/null || true
        sleep 2
    fi
    
    # 创建必要的目录
    sudo mkdir -p /var/run/docker 2>/dev/null || true
    sudo mkdir -p /var/lib/docker 2>/dev/null || true
    
    # 检查是否可以手动启动dockerd
    if [ "$IN_CONTAINER" = "true" ]; then
        log_warning "在容器环境中，可能无法启动Docker守护进程"
        log_info "请确保:"
        log_info "  1. 容器以特权模式运行 (--privileged)"
        log_info "  2. 或者挂载了Docker socket (-v /var/run/docker.sock:/var/run/docker.sock)"
        return 1
    fi
    
    # 手动启动dockerd
    log_info "手动启动Docker守护进程..."
    nohup sudo dockerd \
        --host=unix:///var/run/docker.sock \
        --iptables=false \
        --storage-driver=vfs \
        --exec-opt native.cgroupdriver=cgroupfs \
        --log-level=warn \
        > /tmp/dockerd.log 2>&1 &
    
    # 等待Docker启动
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker info &> /dev/null; then
            log_success "Docker守护进程已启动"
            return 0
        fi
        
        sleep 2
        attempt=$((attempt + 1))
        log_info "等待Docker启动... ($attempt/$max_attempts)"
    done
    
    log_error "Docker启动失败，请检查日志: /tmp/dockerd.log"
    if [ -f "/tmp/dockerd.log" ]; then
        log_info "最近的错误日志:"
        tail -10 /tmp/dockerd.log 2>/dev/null || true
    fi
    return 1
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
    
    # 检查Docker守护进程是否可访问
    if ! docker info &> /dev/null; then
        log_error "无法连接到Docker守护进程"
        
        # 在容器环境中提供特殊提示
        if [ "$IN_CONTAINER" = "true" ]; then
            log_info "容器环境检测提示:"
            log_info "  1. 确保容器以特权模式运行: docker run --privileged"
            log_info "  2. 或挂载Docker socket: -v /var/run/docker.sock:/var/run/docker.sock"
            log_info "  3. 或在宿主机上运行此脚本"
        fi
        return 1
    fi
    
    # 运行hello-world测试（优先使用当前用户，失败时使用sudo）
    log_info "运行Docker hello-world测试..."
    if docker run --rm hello-world &> /dev/null; then
        log_success "Docker安装验证成功（用户权限）"
    elif sudo docker run --rm hello-world &> /dev/null; then
        log_success "Docker安装验证成功（需要sudo权限）"
        log_warning "建议将当前用户添加到docker组以避免使用sudo"
    else
        log_error "Docker hello-world测试失败"
        log_info "调试信息:"
        log_info "  Docker日志: docker logs 或 /tmp/dockerd.log"
        log_info "  系统环境: $INIT_SYSTEM 初始化系统"
        log_info "  容器环境: $IN_CONTAINER"
        return 1
    fi
}

# 处理容器环境下的Docker-in-Docker
handle_docker_in_docker() {
    if [ "$IN_CONTAINER" = "true" ]; then
        log_step "检测到容器环境，配置Docker-in-Docker..."
        
        # 检查是否挂载了Docker socket
        if [ -S "/var/run/docker.sock" ]; then
            log_success "检测到Docker socket挂载，可以使用宿主机Docker"
            SKIP_DOCKER_INSTALL="true"
            return 0
        fi
        
        # 检查是否以特权模式运行
        if [ -f "/.dockerenv" ] && grep -q "0" /proc/sys/kernel/cap_last_cap 2>/dev/null; then
            log_info "检测到特权模式，尝试启动Docker守护进程"
            return 0
        fi
        
        # 提供解决方案
        log_warning "容器环境配置不完整，请选择以下方案之一:"
        echo
        log_info "方案1: 挂载Docker socket（推荐）"
        log_info "  docker run -v /var/run/docker.sock:/var/run/docker.sock ..."
        echo
        log_info "方案2: 特权模式运行"
        log_info "  docker run --privileged ..."
        echo
        log_info "方案3: 在宿主机上直接运行此脚本"
        echo
        log_info "方案4: 跳过Docker安装，直接使用docker-compose"
        echo
        
        read -p "选择方案 (1-4) 或继续尝试安装 (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[4]$ ]]; then
            log_info "用户选择跳过Docker安装"
            SKIP_DOCKER_INSTALL="true"
            return 0
        elif [[ ! $REPLY =~ ^[Yy123]$ ]]; then
            log_info "用户选择退出"
            exit 0
        fi
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
                
                # 优先尝试使用国内镜像源
                log_info "尝试使用国内镜像源安装NVIDIA Docker..."
                if curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - && \
                   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list; then
                    log_success "NVIDIA Docker仓库添加成功"
                else
                    log_warning "NVIDIA Docker仓库添加失败，跳过NVIDIA Docker安装"
                    return 1
                fi
                
                sudo apt update
                if ! sudo apt install -y nvidia-docker2; then
                    log_warning "NVIDIA Docker安装失败，将使用普通Docker"
                    return 1
                fi
                ;;
            "yum")
                distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
                
                # 添加NVIDIA Docker仓库
                if curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo; then
                    log_success "NVIDIA Docker仓库添加成功"
                else
                    log_warning "NVIDIA Docker仓库添加失败，跳过NVIDIA Docker安装"
                    return 1
                fi
                
                if ! sudo yum install -y nvidia-docker2; then
                    log_warning "NVIDIA Docker安装失败，将使用普通Docker"
                    return 1
                fi
                ;;
        esac
        
        # 重启Docker服务
        sudo systemctl restart docker || sudo service docker restart
        
        log_success "NVIDIA Docker安装完成"
    else
        log_info "未检测到NVIDIA GPU，跳过NVIDIA Docker安装"
    fi
}

# 配置Docker镜像加速器
configure_docker_mirror() {
    log_step "配置Docker镜像加速器..."
    
    # 创建Docker配置目录
    sudo mkdir -p /etc/docker
    
    # 配置国内镜像加速器
    cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://docker.mirrors.ustc.edu.cn",
        "https://hub-mirror.c.163.com",
        "https://mirror.baidubce.com",
        "https://ccr.ccs.tencentyun.com"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
EOF
    
    # 重启Docker服务使配置生效
    if command -v systemctl &> /dev/null; then
        sudo systemctl daemon-reload
        sudo systemctl restart docker
        log_success "Docker镜像加速器配置完成（systemctl）"
    elif command -v service &> /dev/null; then
        sudo service docker restart
        log_success "Docker镜像加速器配置完成（service）"
    else
        log_warning "无法重启Docker服务，请手动重启"
    fi
    
    # 验证配置
    if docker info | grep -A 10 "Registry Mirrors" &> /dev/null; then
        log_success "Docker镜像加速器验证成功"
    else
        log_warning "Docker镜像加速器验证失败，但不影响使用"
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
    
    # 检测系统环境
    detect_system_environment
    
    # 检查并安装sudo
    check_and_install_sudo
    
    # 更新系统
    update_system
    
    # 安装基础依赖
    install_dependencies
    
    # 处理容器环境下的Docker-in-Docker
    handle_docker_in_docker
    
    # 检查并安装Docker
    if [ "$SKIP_DOCKER_INSTALL" = "true" ]; then
        log_info "跳过Docker安装，使用现有Docker环境"
        if ! docker info &> /dev/null; then
            log_error "无法连接到Docker，请确保Docker正在运行"
            exit 1
        fi
    elif ! check_docker; then
        install_docker
        start_docker_service
        setup_docker_permissions
        verify_docker
    fi
    
    # 安装NVIDIA Docker（如果需要且未跳过Docker安装）
    if [ "$SKIP_DOCKER_INSTALL" != "true" ]; then
        install_nvidia_docker
        
        # 配置Docker镜像加速器
        configure_docker_mirror
    else
        log_info "跳过NVIDIA Docker和镜像加速器配置"
    fi
    
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