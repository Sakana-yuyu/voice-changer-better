# Voice Changer Better - 实时语音变声器优化版

[English](README_en.md) | [日本語](README_ja.md) | 中文

## 项目简介

这是一个基于深度学习的实时语音变声器项目，支持多种语音变声模型，包括RVC、SoVitsSVC、DDSP-SVC等。本项目基于 [w-okada/voice-changer](https://github.com/w-okada/voice-changer) 进行UI界面优化，提供更好的用户体验。

## 原项目

本项目基于 [w-okada/voice-changer](https://github.com/w-okada/voice-changer) 开发，感谢原作者的优秀工作。

## UI界面优化内容

### 1. 整体布局优化
- **紧凑化设计**：减少了配置区域的间距和内边距，使界面更加紧凑
- **统一宽度**：所有配置子区域采用统一的弹性布局（`flex: 1`），确保视觉一致性
- **响应式布局**：优化了各个控件的最小宽度设置，提高了界面的响应性

### 2. 控制按钮优化
- **尺寸调整**：减小了按钮的字体大小、高度和内边距，使按钮更加紧凑
- **圆角优化**：统一了按钮的圆角半径，提供更现代的视觉效果
- **阴影效果**：优化了按钮的阴影效果，增强了视觉层次感
- **弹性布局**：按钮采用弹性布局，自动适应容器宽度

### 3. 滑块控件优化
- **间距调整**：减少了滑块控件之间的间距，提高空间利用率
- **字体优化**：调整了滑块标签和数值的字体大小，保持清晰可读
- **对齐方式**：优化了滑块控件的对齐方式，确保视觉整齐

### 4. 噪声控制区域优化
- **复选框布局**：优化了复选框容器的间距和字体大小
- **标签对齐**：改进了标签的对齐方式，提供更好的视觉效果

### 5. 字符区域控制优化
- **水平布局**：将增益控制移动到开始/停止/直通按钮的右侧
- **空间节省**：输入/输出增益滑块排列在同一行，节省垂直空间
- **视觉平衡**：通过CSS类 `.character-area-control-field-horizontal` 实现水平布局

## 技术实现

### 主要修改文件
1. **App.css** - 主要样式文件，包含所有UI优化的CSS规则
2. **101_CharacterArea.tsx** - 字符区域组件，实现了增益控制的布局调整

### 关键CSS类
- `.config-area` - 配置区域主容器
- `.config-sub-area` - 配置子区域容器
- `.config-sub-area-buttons` - 按钮容器
- `.config-sub-area-slider-control` - 滑块控件容器
- `.character-area-control-field-horizontal` - 字符区域水平布局

## 项目结构

```
├── client/demo/          # 前端演示应用
│   ├── src/
│   │   ├── css/         # 样式文件
│   │   └── components/  # React组件
│   └── public/          # 静态资源
├── server/              # 后端服务
├── docker/              # Docker配置
└── trainer/             # 模型训练相关
```

## 快速开始

### 🚀 一键自动化部署 (推荐)

使用我们提供的自动化部署脚本，从环境配置到服务启动的全流程自动化部署。

```bash
# 克隆项目
git clone https://github.com/Sakana-yuyu/voice-changer-better.git
cd voice-changer-better

# 给脚本执行权限
chmod +x auto_deploy.sh start_anaconda.sh start_web.sh

# Docker部署（推荐）
./auto_deploy.sh

# 或 Anaconda环境部署
./auto_deploy.sh --anaconda

# 启动Web界面
./start_web.sh
```

### 📋 部署方式选择

| 部署方式 | 优势 | 适用场景 |
|---------|------|----------|
| **Docker部署** | 环境隔离、一键部署、跨平台 | 生产环境、快速体验 |
| **Anaconda部署** | 性能更好、调试方便、资源占用少 | 开发环境、性能要求高 |

### 🐳 Docker 部署

#### 自动化部署
```bash
# 一键Docker部署
./auto_deploy.sh
```

#### 手动部署
```bash
# 构建镜像
docker build -t voice-changer-better:latest .

# GPU版本（推荐）
docker run -d \
  --name voice-changer-better \
  --gpus all \
  -p 6006:6006 \
  -v $(pwd)/docker_folder/model_dir:/voice-changer/server/model_dir \
  -v $(pwd)/docker_folder/pretrain:/resources \
  voice-changer-better:latest

# CPU版本
docker run -d \
  --name voice-changer-better-cpu \
  -p 6006:6006 \
  -v $(pwd)/docker_folder/model_dir:/voice-changer/server/model_dir \
  -v $(pwd)/docker_folder/pretrain:/resources \
  voice-changer-better:latest
```

### 🐍 Anaconda 部署

#### 自动化部署
```bash
# 一键Anaconda部署
./auto_deploy.sh --anaconda
```

#### 启动服务
```bash
# 基本启动
./start_anaconda.sh

# 检查环境
./start_anaconda.sh --check-env

# 强制GPU模式
./start_anaconda.sh --gpu

# 强制CPU模式
./start_anaconda.sh --cpu
```

#### 手动部署
```bash
# 安装Anaconda（如果未安装）
wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
bash Anaconda3-2023.09-0-Linux-x86_64.sh

# 创建Python 3.10环境
conda create -n voice-changer-py310 python=3.10 -y
conda activate voice-changer-py310

# 安装依赖
cd server
pip install -r requirements.txt

# 启动服务
python MMVCServerSIO.py
```

### 🌐 访问应用

启动成功后，在浏览器中访问：
- **变声界面**: http://localhost:6006
- **API接口**: http://localhost:6006/api/hello

### 🛠️ 服务管理

#### Docker容器管理
```bash
# 查看容器状态
docker ps | grep voice-changer

# 查看日志
docker logs -f voice-changer-better

# 停止容器
docker stop voice-changer-better

# 重启容器
docker restart voice-changer-better

# 删除容器
docker rm voice-changer-better

# 进入容器调试
docker exec -it voice-changer-better bash
```

#### Anaconda环境管理
```bash
# 查看环境信息
./start_anaconda.sh --check-env

# 激活环境
conda activate voice-changer-py310

# 更新依赖
./start_anaconda.sh --install-deps

# 重新创建环境
conda env remove -n voice-changer-py310
./auto_deploy.sh --anaconda
```

#### 快速启动Web界面
```bash
# 启动Web界面（自动检测环境）
./start_web.sh

# 指定端口启动
./start_web.sh --port 8080

# 强制使用Docker模式
./start_web.sh --docker

# 强制使用Anaconda模式
./start_web.sh --anaconda

# 检查服务状态
./start_web.sh --status

# 停止服务
./start_web.sh --stop
```

### 📁 模型文件管理

#### 目录结构
```
# Docker部署
docker_folder/
├── model_dir/          # 语音模型文件
└── pretrain/           # 预训练模型文件

# Anaconda部署
server/
├── model_dir/          # 语音模型文件
├── pretrain/           # 预训练模型文件
└── tmp_dir/            # 临时文件目录
```

#### 支持的模型格式
- **语音模型**: `.pth`, `.onnx`, `.safetensors`
- **预训练模型**: `.pth`, `.onnx`, `.bin`
- **配置文件**: `.json`, `.yaml`

### 📋 系统要求

#### 硬件要求
- **CPU**: 4核心以上（推荐8核心）
- **内存**: 8GB RAM以上（推荐16GB）
- **GPU**: NVIDIA GPU（可选，推荐4GB+ VRAM）
- **存储**: 20GB可用空间

#### 软件要求
- **操作系统**: Linux (Ubuntu 18.04+, CentOS 7+), macOS, Windows
- **Docker**: 20.10+ (Docker部署)
- **Python**: 3.8-3.10 (Anaconda部署)
- **CUDA**: 11.8+ (GPU加速)
- **NVIDIA Docker**: 2.0+ (GPU版本)

### ⚠️ 重要注意事项

- **端口**: 默认使用**6006端口**
- **GPU支持**: 需要安装NVIDIA Docker支持
- **内存要求**: 建议至少8GB RAM，GPU版本需要4GB+ VRAM
- **模型文件**: 首次运行前请将模型文件放入对应目录
- **权限**: Linux系统可能需要sudo权限

### 🔧 故障排除

#### 服务无法启动
```bash
# 检查端口占用
netstat -tlnp | grep 6006
# 或使用 lsof -i :6006

# 检查Docker服务
sudo systemctl status docker

# 查看详细日志
docker logs voice-changer-better
# 或 ./start_anaconda.sh --check-env
```

#### GPU相关问题
```bash
# 检查NVIDIA驱动
nvidia-smi

# 检查NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# 重新安装NVIDIA Docker
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

#### 环境问题
```bash
# Anaconda环境问题
conda info --envs
conda activate voice-changer-py310

# 依赖问题
pip install -r server/requirements.txt --upgrade

# 权限问题
sudo chown -R $(id -u):$(id -g) docker_folder/
```

#### 快速验证
```bash
# 检查服务状态
curl http://localhost:6006/api/hello

# 检查容器状态
docker ps | grep voice-changer

# 使用启动脚本检查
./start_web.sh --status
```

### 📚 详细文档

如需更详细的部署指南和配置说明，请参考以下文档：

- **[完整部署指南](LINUX_DEPLOYMENT_GUIDE.md)** - Linux系统完整部署流程
- **[Anaconda环境指南](ANACONDA_SETUP.md)** - Anaconda环境详细配置
- **[Docker配置说明](docker-compose.yml)** - Docker Compose配置文件
- **[开发者指南](client/demo/README.md)** - 前端开发和调试

### 🔄 其他部署方式

#### Docker Compose
```bash
# GPU版本
docker-compose up -d

# CPU版本
docker-compose --profile cpu up -d voice-changer-cpu
```

#### 本地开发
```bash
# 前端开发
cd client/demo && npm install && npm start

# 后端服务
cd server && pip install -r requirements.txt && python MMVCServerSIO.py
```

## ✨ 主要特性

- 🎵 **多模型支持** - RVC、SoVitsSVC、DDSP-SVC等多种变声模型
- 🔄 **实时处理** - 低延迟实时语音变声
- 🎛️ **优化界面** - 紧凑化设计，现代化UI
- 🐳 **容器化** - Docker和Anaconda双重部署方案
- 🚀 **一键部署** - 自动化脚本，开箱即用
- ⚡ **GPU加速** - 支持NVIDIA GPU加速推理
- 📱 **跨平台** - 支持Linux、macOS、Windows
- 🛠️ **易管理** - 完善的服务管理和监控工具

## 许可证

本项目遵循原项目的许可证条款。详见 LICENSE 文件。

## 更新日志

### v1.0.0 (UI优化版)
- 完成整体UI界面的紧凑化设计
- 优化控制按钮和滑块控件的视觉效果
- 实现字符区域控制的水平布局
- 提升用户界面的整体一致性和美观度
