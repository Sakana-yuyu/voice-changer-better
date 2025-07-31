#!/bin/bash

# Voice Changer Better - Anaconda环境启动脚本
# 用于在Anaconda环境下启动Voice Changer服务

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
    echo "Voice Changer Better - Anaconda环境启动脚本"
    echo
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  --help, -h          显示此帮助信息"
    echo "  --check-env         仅检查环境，不启动服务"
    echo "  --install-deps      安装/更新Python依赖"
    echo "  --gpu               强制使用GPU模式（如果可用）"
    echo "  --cpu               强制使用CPU模式"
    echo
    echo "示例:"
    echo "  $0                  # 启动服务"
    echo "  $0 --check-env      # 检查环境"
    echo "  $0 --install-deps   # 安装依赖"
    echo
}

# 解析命令行参数
parse_arguments() {
    CHECK_ONLY=false
    INSTALL_DEPS=false
    FORCE_GPU=false
    FORCE_CPU=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --check-env)
                CHECK_ONLY=true
                shift
                ;;
            --install-deps)
                INSTALL_DEPS=true
                shift
                ;;
            --gpu)
                FORCE_GPU=true
                shift
                ;;
            --cpu)
                FORCE_CPU=true
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

# 检查conda是否可用
check_conda() {
    if ! command -v conda &> /dev/null; then
        log_error "conda命令未找到，请确保Anaconda已正确安装"
        log_info "安装Anaconda: ./auto_deploy.sh --anaconda"
        exit 1
    fi
    
    log_info "检测到conda版本: $(conda --version)"
}

# 激活conda环境
activate_environment() {
    log_step "激活voice-changer-py310环境..."
    
    # 初始化conda - 检测conda.sh的位置
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
        log_error "未找到conda初始化脚本"
        log_info "请检查conda安装路径，支持的路径包括:"
        for path in "${CONDA_SH_PATHS[@]}"; do
            log_info "  - $path"
        done
        exit 1
    fi
    
    # 检查环境是否存在
    if ! conda env list | grep -q "voice-changer-py310"; then
        log_error "voice-changer-py310环境不存在"
        log_info "请先运行: ./auto_deploy.sh --anaconda"
        exit 1
    fi
    
    # 激活环境
    conda activate voice-changer-py310
    log_success "环境激活成功"
}

# 检查Python版本
check_python_version() {
    log_step "检查Python版本..."
    
    PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2)
    log_info "当前Python版本: $PYTHON_VERSION"
    
    # 检查是否为Python 3.10
    if [[ $PYTHON_VERSION =~ ^3\.10\. ]]; then
        log_success "Python版本正确 (3.10.x)"
    else
        log_warning "当前Python版本不是3.10，可能会出现兼容性问题"
    fi
}

# 检查GPU支持
# 检查PyTorch安装状态
check_pytorch_installation() {
    log_step "检查PyTorch安装状态..."
    
    if python -c "import torch" &> /dev/null; then
        PYTORCH_VERSION=$(python -c "import torch; print(torch.__version__)" 2>/dev/null || echo "未知")
        log_info "检测到PyTorch版本: $PYTORCH_VERSION"
        
        # 检查版本是否满足要求（2.0+）
        if python -c "import torch; import sys; sys.exit(0 if tuple(map(int, torch.__version__.split('.')[:2])) >= (2, 0) else 1)" 2>/dev/null; then
            log_success "PyTorch版本满足要求（>=2.0）"
            return 0
        else
            log_warning "PyTorch版本过低（<2.0），建议升级"
            log_info "运行以下命令升级: ./auto_deploy.sh --anaconda"
            return 1
        fi
    else
        log_error "未检测到PyTorch，请先运行: ./auto_deploy.sh --anaconda"
        return 1
    fi
}

check_gpu_support() {
    log_step "检查GPU支持..."
    
    if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
        log_info "检测到NVIDIA GPU:"
        nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits | head -1
        
        # 检查PyTorch GPU支持
        if python -c "import torch; print('GPU可用:', torch.cuda.is_available())" 2>/dev/null; then
            GPU_AVAILABLE=$(python -c "import torch; print(torch.cuda.is_available())" 2>/dev/null)
            if [[ "$GPU_AVAILABLE" == "True" ]]; then
                CUDA_VERSION=$(python -c "import torch; print(torch.version.cuda)" 2>/dev/null || echo "未知")
                log_success "PyTorch GPU支持已启用，CUDA版本: $CUDA_VERSION"
                return 0
            else
                log_warning "PyTorch GPU支持未启用，将使用CPU模式"
                log_info "如需GPU支持，请运行: ./auto_deploy.sh --anaconda"
            fi
        else
            log_warning "无法检查PyTorch GPU支持"
        fi
    else
        log_info "未检测到NVIDIA GPU，将使用CPU模式"
    fi
    
    return 1
}

# 安装/更新依赖
install_dependencies() {
    log_step "安装/更新Python依赖..."
    
    if [[ -f "server/requirements.txt" ]]; then
        log_info "安装requirements.txt中的依赖..."
        pip install -r server/requirements.txt
        log_success "依赖安装完成"
    else
        log_warning "未找到server/requirements.txt文件"
    fi
}

# 检查项目文件
check_project_files() {
    log_step "检查项目文件..."
    
    # 检查是否在正确的目录
    if [[ ! -f "server/MMVCServerSIO.py" ]]; then
        log_error "未找到server/MMVCServerSIO.py，请确保在项目根目录运行此脚本"
        exit 1
    fi
    
    # 检查依赖文件
    if [[ ! -f "server/requirements.txt" ]]; then
        log_warning "未找到server/requirements.txt文件"
    fi
    
    # 检查模型目录
    if [[ ! -d "server/model_dir" ]]; then
        log_info "创建模型目录..."
        mkdir -p server/model_dir
    fi
    
    log_success "项目文件检查完成"
}

# 显示环境信息
show_environment_info() {
    echo
    log_info "=== 环境信息 ==="
    log_info "Conda环境: $(conda info --envs | grep '*' | awk '{print $1}')"
    log_info "Python版本: $(python --version)"
    log_info "工作目录: $(pwd)"
    
    # 显示重要的Python包版本
    if python -c "import torch" &> /dev/null; then
        TORCH_VERSION=$(python -c "import torch; print(torch.__version__)" 2>/dev/null || echo "未知")
        log_info "PyTorch版本: $TORCH_VERSION"
    fi
    
    if python -c "import numpy" &> /dev/null; then
        NUMPY_VERSION=$(python -c "import numpy; print(numpy.__version__)" 2>/dev/null || echo "未知")
        log_info "NumPy版本: $NUMPY_VERSION"
    fi
    
    echo
}

# 主函数
main() {
    # 解析命令行参数
    parse_arguments "$@"
    
    echo "======================================"
    echo "Voice Changer Better - Anaconda启动"
    echo "======================================"
    echo
    
    # 检查conda
    check_conda
    
    # 激活环境
    activate_environment
    
    # 检查Python版本
    check_python_version
    
    # 检查PyTorch安装
    if ! check_pytorch_installation; then
        log_warning "PyTorch检查失败，但继续启动..."
    fi
    
    # 检查项目文件
    check_project_files
    
    # 检查GPU支持
    if [[ "$FORCE_CPU" != "true" ]]; then
        check_gpu_support
        GPU_SUPPORT=$?
    else
        log_info "强制使用CPU模式"
        GPU_SUPPORT=1
    fi
    
    # 安装依赖（如果需要）
    if [[ "$INSTALL_DEPS" == "true" ]]; then
        install_dependencies
    fi
    
    # 显示环境信息
    show_environment_info
    
    # 如果只是检查环境，则退出
    if [[ "$CHECK_ONLY" == "true" ]]; then
        log_success "环境检查完成"
        exit 0
    fi
    
    # 进入服务器目录
    cd server
    
    # 设置环境变量
    if [[ "$FORCE_GPU" == "true" ]] || [[ $GPU_SUPPORT -eq 0 && "$FORCE_CPU" != "true" ]]; then
        export CUDA_VISIBLE_DEVICES="0"
        log_info "启用GPU模式"
    else
        export CUDA_VISIBLE_DEVICES=""
        log_info "使用CPU模式"
    fi
    
    # 启动服务
    log_step "启动Voice Changer服务..."
    log_info "服务将在 http://localhost:6006 启动"
    log_info "按 Ctrl+C 停止服务"
    echo
    
    # 捕获中断信号
    trap 'log_info "正在停止服务..."; exit 0' INT TERM
    
    python MMVCServerSIO.py
}

# 运行主函数
main "$@"