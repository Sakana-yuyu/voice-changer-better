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

### 🐳 使用 Docker 镜像 (推荐)

本项目提供了优化的Docker镜像，在**6006端口**开放变声界面，配置简单，开箱即用。

#### 1. 构建镜像
```bash
# 克隆项目
git clone https://github.com/Sakana-yuyu/voice-changer-better.git
cd voice-changer-better

# 构建Docker镜像
docker build -t voice-changer-better:latest .
```

#### 2. 运行容器

**GPU版本（推荐）：**
```bash
docker run -d \
  --name voice-changer-better \
  --gpus all \
  -p 6006:6006 \
  -v $(pwd)/models:/voice-changer/server/model_dir \
  -v $(pwd)/pretrain:/resources \
  -v $(pwd)/tmp:/voice-changer/server/tmp_dir \
  -e LOCAL_UID=$(id -u) \
  -e LOCAL_GID=$(id -g) \
  voice-changer-better:latest
```

**CPU版本：**
```bash
docker run -d \
  --name voice-changer-better-cpu \
  -p 6006:6006 \
  -v $(pwd)/models:/voice-changer/server/model_dir \
  -v $(pwd)/pretrain:/resources \
  -v $(pwd)/tmp:/voice-changer/server/tmp_dir \
  -e LOCAL_UID=$(id -u) \
  -e LOCAL_GID=$(id -g) \
  voice-changer-better:latest
```

#### 3. 访问应用
启动成功后，在浏览器中访问：
- **变声界面**: http://localhost:6006

#### 4. 容器管理
```bash
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

#### 5. 目录说明
- `models/`: 存放语音模型文件（.pth格式）
- `pretrain/`: 存放预训练模型文件（.pth, .onnx格式）
- `tmp/`: 临时文件目录

#### 6. 注意事项
- **端口变更**: 新版Docker镜像使用**6006端口**而非传统的18888端口
- **自动用户管理**: 容器会自动创建与宿主机UID/GID匹配的用户，避免权限问题
- **GPU支持**: 确保已安装NVIDIA Docker支持（`nvidia-docker2`）
- **内存要求**: 建议至少8GB RAM，GPU版本需要4GB+ VRAM
- **模型文件**: 首次运行前请将模型文件放入对应的挂载目录

#### 7. 故障排除

**容器无法启动：**
```bash
# 检查Docker是否运行
sudo systemctl status docker

# 检查端口是否被占用
sudo netstat -tlnp | grep 6006

# 查看详细错误日志
docker logs voice-changer-better
```

**GPU不可用：**
```bash
# 检查NVIDIA Docker支持
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# 如果失败，安装nvidia-docker2
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

**权限问题：**
```bash
# 确保目录权限正确
sudo chown -R $(id -u):$(id -g) models/ pretrain/ tmp/

# 或使用sudo运行容器
sudo docker run ...
```

#### 8. 快速测试

**验证服务是否正常运行：**
```bash
# 检查容器状态
docker ps | grep voice-changer-better

# 测试API接口
curl http://localhost:6006/api/hello

# 检查健康状态
docker inspect --format='{{.State.Health.Status}}' voice-changer-better
```

**访问Web界面：**
1. 打开浏览器访问 http://localhost:6006
2. 如果看到Voice Changer界面，说明部署成功
3. 上传模型文件到 `models/` 目录
4. 在界面中选择模型开始使用

### 使用传统 Docker Compose

#### 1. 使用 docker-compose (最简单)
```bash
# GPU 版本
docker-compose up -d

# CPU 版本
docker-compose --profile cpu up -d voice-changer-cpu
```

#### 2. 使用构建脚本
```bash
# 构建镜像
chmod +x scripts/build-docker.sh
./scripts/build-docker.sh

# 部署服务
chmod +x scripts/deploy.sh
./scripts/deploy.sh --mode gpu --port 18888
```

#### 3. 手动 Docker 命令
```bash
# 构建镜像
docker build -t voice-changer-better .

# 运行容器 (GPU)
docker run -d --name voice-changer --gpus all -p 18888:18888 voice-changer-better

# 运行容器 (CPU)
docker run -d --name voice-changer -p 18888:18888 voice-changer-better
```

### 本地开发

#### 前端开发
```bash
cd client/demo
npm install
npm start
```

#### 后端服务
```bash
cd server
pip install -r requirements.txt
python MMVCServerSIO.py
```

## 特性

- 🎵 支持多种语音变声模型
- 🔄 实时语音处理
- 🎛️ 直观的用户界面
- 📱 响应式设计
- ⚡ 优化的性能
- 🎨 现代化的UI设计
- 🐳 Docker 容器化支持
- 🚀 自动化 CI/CD 流程
- 📦 多平台镜像支持

## 部署选项

### 1. Docker 部署 (推荐)
- 支持 GPU 和 CPU 模式
- 一键部署脚本
- 自动健康检查
- 数据持久化

### 2. 云平台部署
- 支持 Kubernetes
- 支持 Docker Swarm
- 支持各大云服务商

### 3. 本地开发
- 热重载开发环境
- 完整的开发工具链
- 代码质量检查

## 环境要求

### 系统要求
- **操作系统**: Linux, macOS, Windows
- **内存**: 最少 4GB RAM (推荐 8GB+)
- **存储**: 最少 10GB 可用空间
- **GPU**: NVIDIA GPU (可选，用于加速)

### 软件依赖
- **Docker**: 20.10+ (用于容器化部署)
- **Docker Compose**: 2.0+ (用于编排)
- **Node.js**: 18+ (用于前端开发)
- **Python**: 3.8+ (用于后端开发)
- **CUDA**: 11.8+ (用于 GPU 加速)

## 许可证

本项目遵循原项目的许可证条款。详见 LICENSE 文件。

## 更新日志

### v1.0.0 (UI优化版)
- 完成整体UI界面的紧凑化设计
- 优化控制按钮和滑块控件的视觉效果
- 实现字符区域控制的水平布局
- 提升用户界面的整体一致性和美观度
