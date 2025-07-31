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
USE_ANACONDA="false"
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

# 安装Anaconda和Python 3.10环境
install_anaconda_environment() {
    log_step "安装Anaconda和Python 3.10环境..."
    
    # 检查是否已安装conda
    if command -v conda &> /dev/null; then
        log_info "检测到已安装的conda环境"
        CONDA_VERSION=$(conda --version | cut -d' ' -f2)
        log_info "Conda版本: $CONDA_VERSION"
    else
        log_info "开始下载和安装Anaconda..."
        
        # 创建临时目录
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # 检测系统架构
        ARCH=$(uname -m)
        if [[ "$ARCH" == "x86_64" ]]; then
            ANACONDA_INSTALLER="Anaconda3-2023.09-0-Linux-x86_64.sh"
        elif [[ "$ARCH" == "aarch64" ]]; then
            ANACONDA_INSTALLER="Anaconda3-2023.09-0-Linux-aarch64.sh"
        else
            log_error "不支持的系统架构: $ARCH"
            return 1
        fi
        
        # 多个镜像源下载Anaconda安装包
        log_info "下载Anaconda安装包..."
        DOWNLOAD_SUCCESS=false
        
        # 镜像源列表（按优先级排序）
        MIRRORS=(
            "https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive"
            "https://mirrors.ustc.edu.cn/anaconda/archive"
            "https://mirrors.aliyun.com/anaconda/archive"
            "https://repo.anaconda.com/archive"
        )
        
        for mirror in "${MIRRORS[@]}"; do
            log_info "尝试从 $mirror 下载..."
            if wget -q --show-progress "$mirror/$ANACONDA_INSTALLER"; then
                log_success "从 $mirror 下载成功"
                DOWNLOAD_SUCCESS=true
                break
            else
                log_warning "从 $mirror 下载失败，尝试下一个镜像源..."
            fi
        done
        
        if [[ "$DOWNLOAD_SUCCESS" != "true" ]]; then
            log_error "所有镜像源下载失败"
            return 1
        fi
        
        # 安装Anaconda
        log_info "安装Anaconda到 $HOME/anaconda3..."
        bash "$ANACONDA_INSTALLER" -b -p "$HOME/anaconda3"
        
        # 初始化conda
        log_info "初始化conda环境..."
        "$HOME/anaconda3/bin/conda" init bash
        
        # 添加conda到PATH
        export PATH="$HOME/anaconda3/bin:$PATH"
        
        # 清理临时文件
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        
        log_success "Anaconda安装完成"
    fi
    
    # 动态检测conda安装路径并确保在PATH中
    CONDA_PATHS=(
        "$HOME/anaconda3/bin"
        "/root/anaconda3/bin"
        "/opt/anaconda3/bin"
        "/usr/local/anaconda3/bin"
        "/opt/miniconda3/bin"
        "$HOME/miniconda3/bin"
    )
    
    CONDA_BIN_FOUND=false
    for conda_bin_path in "${CONDA_PATHS[@]}"; do
        if [[ -d "$conda_bin_path" ]] && [[ -f "$conda_bin_path/conda" ]]; then
            if [[ ":$PATH:" != *":$conda_bin_path:"* ]]; then
                export PATH="$conda_bin_path:$PATH"
                log_info "添加conda路径到PATH: $conda_bin_path"
            fi
            CONDA_BIN_FOUND=true
            break
        fi
    done
    
    if [[ "$CONDA_BIN_FOUND" != "true" ]]; then
        log_warning "未找到conda可执行文件，尝试使用默认路径"
    fi
    
    # 配置conda镜像源
    log_info "配置conda镜像源..."
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/pro
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
    conda config --set show_channel_urls yes
    
    # 配置pip镜像源
    log_info "配置pip镜像源..."
    mkdir -p ~/.pip
    cat > ~/.pip/pip.conf << EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
extra-index-url = https://mirrors.aliyun.com/pypi/simple/
                  https://pypi.mirrors.ustc.edu.cn/simple/
                  https://pypi.douban.com/simple/
trusted-host = pypi.tuna.tsinghua.edu.cn
               mirrors.aliyun.com
               pypi.mirrors.ustc.edu.cn
               pypi.douban.com
EOF
    
    # 创建Python 3.10环境
    log_info "创建Python 3.10虚拟环境..."
    
    # 检查环境是否已存在
    if conda env list | grep -q "voice-changer-py310"; then
        log_info "检测到已存在的voice-changer-py310环境"
        read -p "是否重新创建环境？(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            conda env remove -n voice-changer-py310 -y
        else
            log_info "使用现有环境"
            return 0
        fi
    fi
    
    # 创建新环境
    log_info "创建voice-changer-py310环境..."
    conda create -n voice-changer-py310 python=3.10 -y
    
    # 激活环境并安装依赖
    log_info "激活环境并安装Python依赖..."
    
    # 检测conda.sh的位置
    CONDA_SH_PATHS=(
        "$HOME/anaconda3/etc/profile.d/conda.sh"
        "/root/anaconda3/etc/profile.d/conda.sh"
        "/opt/anaconda3/etc/profile.d/conda.sh"
        "/usr/local/anaconda3/etc/profile.d/conda.sh"
        "/opt/miniconda3/etc/profile.d/conda.sh"
        "$HOME/miniconda3/etc/profile.d/conda.sh"
    )
    
    CONDA_SH_FOUND=false
    for conda_sh_path in "${CONDA_SH_PATHS[@]}"; do
        if [[ -f "$conda_sh_path" ]]; then
            log_info "找到conda.sh: $conda_sh_path"
            source "$conda_sh_path"
            CONDA_SH_FOUND=true
            break
        fi
    done
    
    if [[ "$CONDA_SH_FOUND" != "true" ]]; then
        log_warning "未找到conda.sh，尝试直接激活环境..."
        # 如果找不到conda.sh，尝试直接使用conda命令
        if ! conda activate voice-changer-py310 2>/dev/null; then
            log_error "无法激活conda环境，请检查conda安装"
            log_info "请手动运行以下命令激活环境:"
            log_info "conda activate voice-changer-py310"
            return 1
        fi
    else
        conda activate voice-changer-py310
    fi
    
    # 检查PyTorch是否已安装
    log_info "检查PyTorch安装状态..."
    PYTORCH_INSTALLED=false
    PYTORCH_VERSION=""
    PYTORCH_CUDA_AVAILABLE=false
    
    if python -c "import torch" &> /dev/null; then
        PYTORCH_INSTALLED=true
        PYTORCH_VERSION=$(python -c "import torch; print(torch.__version__)" 2>/dev/null || echo "未知")
        log_info "检测到已安装的PyTorch版本: $PYTORCH_VERSION"
        
        # 检查CUDA支持
        if python -c "import torch; print(torch.cuda.is_available())" 2>/dev/null | grep -q "True"; then
            PYTORCH_CUDA_AVAILABLE=true
            CUDA_VERSION=$(python -c "import torch; print(torch.version.cuda)" 2>/dev/null || echo "未知")
            log_info "PyTorch支持CUDA，版本: $CUDA_VERSION"
        else
            log_info "PyTorch不支持CUDA或仅CPU版本"
        fi
        
        # 检查版本是否满足要求（2.0+）
        if python -c "import torch; import sys; sys.exit(0 if tuple(map(int, torch.__version__.split('.')[:2])) >= (2, 0) else 1)" 2>/dev/null; then
            log_success "PyTorch版本满足要求（>=2.0）"
            
            # 检查GPU支持是否匹配
            if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
                if [[ "$PYTORCH_CUDA_AVAILABLE" == "true" ]]; then
                    log_success "检测到NVIDIA GPU且PyTorch支持CUDA，使用现有安装"
                    SKIP_PYTORCH_INSTALL=true
                else
                    log_warning "检测到NVIDIA GPU但PyTorch不支持CUDA，将重新安装GPU版本"
                    SKIP_PYTORCH_INSTALL=false
                fi
            else
                log_success "CPU环境，使用现有PyTorch安装"
                SKIP_PYTORCH_INSTALL=true
            fi
        else
            log_warning "PyTorch版本过低（<2.0），将升级到最新版本"
            SKIP_PYTORCH_INSTALL=false
        fi
    else
        log_info "未检测到PyTorch，将进行安装"
        SKIP_PYTORCH_INSTALL=false
    fi
    
    # 根据检测结果决定是否安装PyTorch
    if [[ "$SKIP_PYTORCH_INSTALL" != "true" ]]; then
        if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
            log_info "检测到NVIDIA GPU，安装GPU版本PyTorch..."
            # 安装GPU版本PyTorch
            conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia -y
        else
            log_info "未检测到NVIDIA GPU，安装CPU版本PyTorch..."
            # 安装CPU版本PyTorch
            conda install pytorch torchvision torchaudio cpuonly -c pytorch -y
        fi
        
        # 验证安装
        if python -c "import torch" &> /dev/null; then
            NEW_PYTORCH_VERSION=$(python -c "import torch; print(torch.__version__)" 2>/dev/null || echo "未知")
            log_success "PyTorch安装完成，版本: $NEW_PYTORCH_VERSION"
        else
            log_error "PyTorch安装失败"
            return 1
        fi
    else
        log_info "跳过PyTorch安装，使用现有版本: $PYTORCH_VERSION"
    fi
    
    # 安装项目依赖
    if [[ -f "server/requirements.txt" ]]; then
        log_info "安装项目依赖..."
        pip install -r server/requirements.txt
    fi
    
    log_success "Anaconda和Python 3.10环境配置完成"
    log_info "环境名称: voice-changer-py310"
    log_info "激活命令: conda activate voice-changer-py310"
    log_info "Python版本: $(python --version)"
}

# 运行Python版本（不使用Docker）
run_python_version() {
    log_step "启动Python版本的Voice Changer..."
    
    # 检查是否在conda环境中
    if [[ "$USE_ANACONDA" == "true" ]]; then
        # 动态检测conda安装路径并确保在PATH中
        CONDA_PATHS=(
            "$HOME/anaconda3/bin"
            "/root/anaconda3/bin"
            "/opt/anaconda3/bin"
            "/usr/local/anaconda3/bin"
            "/opt/miniconda3/bin"
            "$HOME/miniconda3/bin"
        )
        
        CONDA_BIN_FOUND=false
        for conda_bin_path in "${CONDA_PATHS[@]}"; do
            if [[ -d "$conda_bin_path" ]] && [[ -f "$conda_bin_path/conda" ]]; then
                if [[ ":$PATH:" != *":$conda_bin_path:"* ]]; then
                    export PATH="$conda_bin_path:$PATH"
                fi
                CONDA_BIN_FOUND=true
                break
            fi
        done
        
        # 激活conda环境 - 检测conda.sh的位置
        CONDA_SH_PATHS=(
            "$HOME/anaconda3/etc/profile.d/conda.sh"
            "/root/anaconda3/etc/profile.d/conda.sh"
            "/opt/anaconda3/etc/profile.d/conda.sh"
            "/usr/local/anaconda3/etc/profile.d/conda.sh"
            "/opt/miniconda3/etc/profile.d/conda.sh"
            "$HOME/miniconda3/etc/profile.d/conda.sh"
        )
        
        CONDA_SH_FOUND=false
        for conda_sh_path in "${CONDA_SH_PATHS[@]}"; do
            if [[ -f "$conda_sh_path" ]]; then
                source "$conda_sh_path"
                CONDA_SH_FOUND=true
                break
            fi
        done
        
        if [[ "$CONDA_SH_FOUND" != "true" ]]; then
            log_warning "未找到conda.sh，尝试直接激活环境..."
            if ! conda activate voice-changer-py310 2>/dev/null; then
                log_error "无法激活conda环境，请检查conda安装"
                return 1
            fi
        else
            conda activate voice-changer-py310
        fi
        log_info "已激活conda环境: voice-changer-py310"
    fi
    
    # 检查Python版本
    PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2)
    log_info "当前Python版本: $PYTHON_VERSION"
    
    # 进入服务器目录
    cd server
    
    # 检查依赖
    if [[ ! -f "requirements.txt" ]]; then
        log_error "未找到requirements.txt文件"
        return 1
    fi
    
    # 安装依赖（如果需要）
    log_info "检查并安装Python依赖..."
    pip install -r requirements.txt
    
    # 启动服务
    log_info "启动Voice Changer服务..."
    log_info "服务将在 http://localhost:6006 启动"
    log_info "按 Ctrl+C 停止服务"
    
    python MMVCServerSIO.py
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
            # 检测系统版本
            DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
            CODENAME=$(lsb_release -cs)
            
            log_info "检测到系统: $DISTRO $CODENAME"
            
            # 多个镜像源尝试安装Docker
            DOCKER_MIRRORS=(
                "https://mirrors.aliyun.com/docker-ce/linux/$DISTRO"
                "https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/$DISTRO"
                "https://mirrors.ustc.edu.cn/docker-ce/linux/$DISTRO"
                "https://download.docker.com/linux/$DISTRO"
            )
            
            INSTALL_SUCCESS=false
            
            for mirror in "${DOCKER_MIRRORS[@]}"; do
                log_info "尝试使用镜像源: $mirror"
                
                # 清理之前可能失败的配置
                sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg
                sudo rm -f /etc/apt/sources.list.d/docker.list
                
                # 添加GPG密钥
                if curl -fsSL "$mirror/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null; then
                    log_info "GPG密钥添加成功"
                    
                    # 添加Docker仓库
                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] $mirror $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                    
                    # 更新包索引
                    if sudo apt update 2>/dev/null; then
                        log_info "软件源更新成功"
                        
                        # 尝试安装Docker
                        if sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null; then
                            log_success "Docker安装成功（使用 $mirror）"
                            INSTALL_SUCCESS=true
                            break
                        else
                            log_warning "Docker安装失败，尝试下一个镜像源..."
                        fi
                    else
                        log_warning "软件源更新失败，尝试下一个镜像源..."
                    fi
                else
                    log_warning "GPG密钥添加失败，尝试下一个镜像源..."
                fi
            done
            
            # 如果所有镜像源都失败，尝试使用系统默认仓库
            if [[ "$INSTALL_SUCCESS" != "true" ]]; then
                log_warning "所有Docker镜像源安装失败，尝试使用系统默认仓库..."
                sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg
                sudo rm -f /etc/apt/sources.list.d/docker.list
                sudo apt update
                if sudo apt install -y docker.io docker-compose; then
                    log_success "Docker安装成功（使用系统默认仓库）"
                    INSTALL_SUCCESS=true
                else
                    log_error "Docker安装完全失败"
                    return 1
                fi
            fi
            ;;
        "yum")
            # 检测系统版本
            if [[ -f /etc/redhat-release ]]; then
                DISTRO="centos"
            else
                DISTRO="rhel"
            fi
            
            log_info "检测到系统: $DISTRO"
            
            # 多个镜像源尝试安装Docker
            DOCKER_YUM_MIRRORS=(
                "https://mirrors.aliyun.com/docker-ce/linux/$DISTRO/docker-ce.repo"
                "https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/$DISTRO/docker-ce.repo"
                "https://download.docker.com/linux/$DISTRO/docker-ce.repo"
            )
            
            INSTALL_SUCCESS=false
            
            for mirror in "${DOCKER_YUM_MIRRORS[@]}"; do
                log_info "尝试使用镜像源: $mirror"
                
                # 清理之前可能失败的配置
                sudo rm -f /etc/yum.repos.d/docker-ce.repo
                
                # 添加Docker仓库
                if sudo yum-config-manager --add-repo "$mirror" 2>/dev/null; then
                    log_info "Docker仓库添加成功"
                    
                    # 尝试安装Docker
                    if sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null; then
                        log_success "Docker安装成功（使用 $mirror）"
                        INSTALL_SUCCESS=true
                        break
                    else
                        log_warning "Docker安装失败，尝试下一个镜像源..."
                    fi
                else
                    log_warning "Docker仓库添加失败，尝试下一个镜像源..."
                fi
            done
            
            # 如果所有镜像源都失败，尝试使用系统默认仓库
            if [[ "$INSTALL_SUCCESS" != "true" ]]; then
                log_warning "所有Docker镜像源安装失败，尝试使用系统默认仓库..."
                sudo rm -f /etc/yum.repos.d/docker-ce.repo
                if sudo yum install -y docker docker-compose; then
                    log_success "Docker安装成功（使用系统默认仓库）"
                    INSTALL_SUCCESS=true
                else
                    log_error "Docker安装完全失败"
                    return 1
                fi
            fi
            ;;
    esac
    
    if [[ "$INSTALL_SUCCESS" == "true" ]]; then
        log_success "Docker安装完成"
        
        # 显示安装的Docker版本
        DOCKER_VERSION=$(docker --version 2>/dev/null || echo "未知版本")
        log_info "安装的Docker版本: $DOCKER_VERSION"
    else
        log_error "Docker安装失败"
        return 1
    fi
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
    
    # 备份原有配置
    if [[ -f "/etc/docker/daemon.json" ]]; then
        sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup
        log_info "已备份原有Docker配置"
    fi
    
    # 配置国内镜像加速器（更多镜像源）
    cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://docker.mirrors.ustc.edu.cn",
        "https://hub-mirror.c.163.com",
        "https://mirror.baidubce.com",
        "https://ccr.ccs.tencentyun.com",
        "https://dockerproxy.com",
        "https://mirror.iscas.ac.cn",
        "https://docker.nju.edu.cn",
        "https://docker.mirrors.sjtug.sjtu.edu.cn"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "exec-opts": ["native.cgroupdriver=systemd"],
    "live-restore": true,
    "userland-proxy": false,
    "experimental": false
}
EOF
    
    # 重启Docker服务使配置生效
    if command -v systemctl &> /dev/null; then
        sudo systemctl daemon-reload
        if sudo systemctl restart docker; then
            log_success "Docker镜像加速器配置完成（systemctl）"
        else
            log_warning "Docker服务重启失败，恢复备份配置"
            if [[ -f "/etc/docker/daemon.json.backup" ]]; then
                sudo mv /etc/docker/daemon.json.backup /etc/docker/daemon.json
                sudo systemctl restart docker
            fi
            return 1
        fi
    elif command -v service &> /dev/null; then
        if sudo service docker restart; then
            log_success "Docker镜像加速器配置完成（service）"
        else
            log_warning "Docker服务重启失败，恢复备份配置"
            if [[ -f "/etc/docker/daemon.json.backup" ]]; then
                sudo mv /etc/docker/daemon.json.backup /etc/docker/daemon.json
                sudo service docker restart
            fi
            return 1
        fi
    else
        log_warning "无法重启Docker服务，请手动重启"
    fi
    
    # 等待Docker服务完全启动
    sleep 5
    
    # 验证配置
    if docker info | grep -A 15 "Registry Mirrors" &> /dev/null; then
        log_success "Docker镜像加速器验证成功"
        log_info "已配置的镜像源:"
        docker info | grep -A 15 "Registry Mirrors" | grep "https://" | sed 's/^[ ]*//'
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

# 显示帮助信息
show_help() {
    echo "Voice Changer Better 自动化部署脚本"
    echo
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  --anaconda          使用Anaconda和Python 3.10环境（不使用Docker）"
    echo "  --skip-docker       跳过Docker安装，使用现有Docker环境"
    echo "  --help, -h          显示此帮助信息"
    echo
    echo "示例:"
    echo "  $0                   # 默认Docker部署"
    echo "  $0 --anaconda       # 使用Anaconda环境部署"
    echo "  $0 --skip-docker    # 跳过Docker安装"
    echo
}

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --anaconda)
                USE_ANACONDA="true"
                SKIP_DOCKER_INSTALL="true"
                shift
                ;;
            --skip-docker)
                SKIP_DOCKER_INSTALL="true"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 主函数
main() {
    # 解析命令行参数
    parse_arguments "$@"
    
    echo "======================================"
    echo "Voice Changer Better 自动化部署脚本"
    echo "======================================"
    echo
    
    if [[ "$USE_ANACONDA" == "true" ]]; then
        log_info "模式: Anaconda + Python 3.10 环境"
    else
        log_info "模式: Docker 容器化部署"
    fi
    
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
    
    # 根据选择的模式执行不同的部署流程
    if [[ "$USE_ANACONDA" == "true" ]]; then
        log_info "开始Anaconda环境部署..."
        
        # 安装Anaconda和Python 3.10环境
        install_anaconda_environment
        
        # 运行Python版本
        run_python_version
    else
        log_info "开始Docker容器化部署..."
        
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
    fi
    
    echo
    log_success "🎉 Voice Changer Better 部署完成！"
    echo
}

# 错误处理
trap 'log_error "脚本执行失败，请检查错误信息"; exit 1' ERR

# 运行主函数
main "$@"