# Voice Changer Better - Anaconda环境部署指南

> 📖 **主要文档**: [返回主README](README.md) | [Docker部署指南](LINUX_DEPLOYMENT_GUIDE.md)

本指南提供Anaconda和Python 3.10环境下的详细部署说明。如需快速开始，请参考[主README](README.md#快速开始)。

## 快速开始

### 自动安装

```bash
# 使用Anaconda环境部署
./auto_deploy.sh --anaconda
```

### 启动服务

```bash
# 基本启动
./start_anaconda.sh

# 检查环境
./start_anaconda.sh --check-env

# 安装依赖
./start_anaconda.sh --install-deps

# 强制GPU模式
./start_anaconda.sh --gpu

# 强制CPU模式
./start_anaconda.sh --cpu
```

## 系统要求

- **操作系统**: Linux (Ubuntu 18.04+, CentOS 7+, Debian 9+)
- **内存**: 至少 4GB RAM (推荐 8GB+)
- **存储**: 至少 15GB 可用空间
- **网络**: 稳定的互联网连接（用于下载依赖）
- **GPU**: NVIDIA GPU（可选，用于加速推理）
- **CUDA**: 11.8+ (如果使用GPU)

## 详细安装步骤

### 1. 下载项目

```bash
git clone https://github.com/your-repo/voice-changer-better.git
cd voice-changer-better
```

### 2. 运行自动部署脚本

```bash
# 给脚本执行权限
chmod +x auto_deploy.sh start_anaconda.sh

# 使用Anaconda环境部署
./auto_deploy.sh --anaconda
```

脚本将自动完成以下操作：
- 检查系统环境和依赖
- 从多个镜像源下载并安装Anaconda
- 创建Python 3.10虚拟环境 (voice-changer-py310)
- 配置conda和pip镜像源
- 根据GPU可用性安装PyTorch (CPU/GPU版本)
- 安装项目依赖包
- 配置环境变量

### 3. 启动服务

```bash
# 使用启动脚本
./start_anaconda.sh

# 或查看帮助
./start_anaconda.sh --help
```

## 使用方法

### 启动选项

```bash
# 显示帮助信息
./start_anaconda.sh --help

# 仅检查环境，不启动服务
./start_anaconda.sh --check-env

# 安装/更新Python依赖
./start_anaconda.sh --install-deps

# 强制使用GPU模式（如果可用）
./start_anaconda.sh --gpu

# 强制使用CPU模式
./start_anaconda.sh --cpu
```

### 访问Web界面

服务启动后，在浏览器中访问：
```
http://localhost:6006
```

### 模型文件放置

将您的模型文件放置在以下目录：
```
server/model_dir/
```

支持的模型格式：
- `.pth` 文件 (PyTorch模型)
- `.onnx` 文件 (ONNX模型)
- `.safetensors` 文件 (SafeTensors格式)

### 预训练模型

预训练模型应放置在：
```
server/pretrain/
```

## 环境管理

### 查看环境信息

```bash
# 使用启动脚本检查环境
./start_anaconda.sh --check-env

# 手动激活环境
conda activate voice-changer-py310

# 查看Python版本
python --version

# 查看已安装的包
conda list

# 查看PyTorch版本和GPU支持
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA可用: {torch.cuda.is_available()}')"
```

### 更新依赖

```bash
# 使用启动脚本更新依赖
./start_anaconda.sh --install-deps

# 或手动更新
conda activate voice-changer-py310
pip install -r server/requirements.txt --upgrade
```

### 重新创建环境

```bash
# 删除现有环境
conda env remove -n voice-changer-py310

# 重新运行部署脚本
./auto_deploy.sh --anaconda
```

## 故障排除

### 常见问题

**Q: conda命令未找到**
```bash
# 解决方案：重新运行部署脚本
./auto_deploy.sh --anaconda

# 或手动添加到PATH
export PATH="$HOME/anaconda3/bin:$PATH"
source ~/.bashrc
```

**Q: Python版本不正确**
```bash
# 检查当前环境
conda info --envs

# 激活正确的环境
conda activate voice-changer-py310

# 验证Python版本
python --version
```

**Q: 依赖安装失败**
```bash
# 清理pip缓存
pip cache purge

# 使用启动脚本重新安装
./start_anaconda.sh --install-deps

# 或手动安装
conda activate voice-changer-py310
pip install -r server/requirements.txt --no-cache-dir
```

**Q: GPU不可用**
```bash
# 检查NVIDIA驱动
nvidia-smi

# 检查CUDA版本
nvcc --version

# 检查PyTorch GPU支持
python -c "import torch; print('CUDA可用:', torch.cuda.is_available()); print('GPU数量:', torch.cuda.device_count())"

# 强制使用CPU模式
./start_anaconda.sh --cpu
```

**Q: 服务启动失败**
```bash
# 检查端口占用
netstat -tlnp | grep 6006

# 检查环境
./start_anaconda.sh --check-env

# 查看详细错误信息
conda activate voice-changer-py310
cd server
python MMVCServerSIO.py
```

**Q: 下载速度慢**
```bash
# 脚本已配置多个镜像源，会自动选择最快的
# 如果仍然很慢，可以手动配置镜像源：

# conda镜像源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/

# pip镜像源
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

### 日志查看

```bash
# 启动脚本会显示详细的日志信息
./start_anaconda.sh

# 如果有日志文件
tail -f logs/voice_changer.log
```

## 配置文件

### 主要配置文件

- `server/config.json`: 主配置文件
- `server/model_config.json`: 模型配置
- `.env`: 环境变量配置

### 自定义配置

您可以通过修改配置文件来自定义服务行为：

```json
{
  "server_port": 6006,
  "model_dir": "./model_dir",
  "device": "auto",
  "max_workers": 4,
  "enable_gpu": true
}
```

### 环境变量

```bash
# GPU相关
export CUDA_VISIBLE_DEVICES="0"  # 指定GPU
export CUDA_VISIBLE_DEVICES=""   # 禁用GPU

# 内存优化
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:128"
```

## 性能优化

### GPU优化

```bash
# 检查GPU状态
nvidia-smi

# 使用GPU模式启动
./start_anaconda.sh --gpu

# 设置GPU内存分配
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:256"
```

### CPU优化

```bash
# 设置CPU线程数
export OMP_NUM_THREADS=4
export MKL_NUM_THREADS=4

# 使用CPU模式启动
./start_anaconda.sh --cpu
```

## 卸载指南

### 完全卸载

```bash
# 删除conda环境
conda env remove -n voice-changer-py310

# 删除Anaconda（可选）
rm -rf ~/anaconda3

# 清理配置文件
rm -rf ~/.conda
rm -rf ~/.condarc

# 删除项目文件
rm -rf voice-changer-better
```

### 仅删除环境

```bash
# 只删除Python环境，保留Anaconda
conda env remove -n voice-changer-py310
```

## 支持信息

### 获取帮助

- 查看部署脚本帮助：`./auto_deploy.sh --help`
- 查看启动脚本帮助：`./start_anaconda.sh --help`
- 项目文档：[README.md](README.md)
- Linux部署指南：[LINUX_DEPLOYMENT_GUIDE.md](LINUX_DEPLOYMENT_GUIDE.md)
- 问题反馈：[GitHub Issues](https://github.com/your-repo/voice-changer-better/issues)

### 版本信息

- Python: 3.10.x
- PyTorch: 最新稳定版 (支持CUDA 11.8+)
- Anaconda: 最新版本
- 支持的CUDA版本: 11.8, 12.0, 12.1

### 镜像源配置

脚本自动配置了以下镜像源：

**Anaconda下载源:**
- 清华大学镜像
- 中国科学技术大学镜像
- 阿里云镜像
- 官方源（备用）

**Conda包源:**
- 清华大学镜像
- 中科大镜像
- 北京外国语大学镜像

**PyPI源:**
- 清华大学镜像
- 阿里云镜像
- 中科大镜像
- 豆瓣镜像

## 优势对比

### 相比Docker部署的优势

1. **性能更好**: 直接在宿主机运行，无容器开销
2. **资源占用少**: 不需要Docker镜像存储空间
3. **调试方便**: 可以直接访问Python环境和代码
4. **自定义性强**: 可以轻松修改Python包和配置
5. **GPU支持更好**: 直接访问GPU，无需额外配置
6. **启动速度快**: 无需构建和启动容器
7. **内存使用效率高**: 无容器层开销

### 适用场景

- 开发和调试环境
- 需要频繁修改代码的场景
- 对性能要求较高的生产环境
- 需要自定义Python包的场景
- GPU资源有限的环境
- 需要精确控制依赖版本的场景

### 部署模式选择建议

| 场景 | 推荐模式 | 原因 |
|------|----------|------|
| 开发调试 | Anaconda | 便于调试和修改 |
| 生产环境 | Docker | 环境隔离和部署一致性 |
| GPU加速 | Anaconda | 更好的GPU性能 |
| 多用户环境 | Docker | 资源隔离 |
| 快速体验 | Anaconda | 启动速度快 |

---

**注意**: 本指南适用于Linux环境。脚本已针对Ubuntu、CentOS、Debian等主流发行版进行了优化，支持多种包管理器和镜像源。