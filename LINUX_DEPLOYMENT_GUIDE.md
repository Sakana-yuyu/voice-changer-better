# Voice Changer Better Linux 部署完整指南

> 📖 **主要文档**: [返回主README](README.md) | [Anaconda部署指南](ANACONDA_SETUP.md)

本文档提供Linux系统的完整部署流程。如需快速开始，请参考[主README](README.md#快速开始)。

## 📋 系统要求

### 硬件要求
- **CPU**: 4核心以上（推荐8核心）
- **内存**: 8GB RAM以上（推荐16GB）
- **GPU**: NVIDIA GPU（可选，推荐4GB+ VRAM）
- **存储**: 20GB可用空间

### 软件要求
- **操作系统**: Ubuntu 18.04+ / CentOS 7+ / Debian 10+
- **Docker**: 20.10+
- **Docker Compose**: 1.29+
- **NVIDIA Docker**: 2.0+（GPU版本需要）

## 🚀 快速开始：一键自动化部署

**如果您希望快速部署，可以使用我们提供的自动化脚本，跳过手动配置步骤。**

### 使用自动化部署脚本

项目中包含了 `auto_deploy.sh` 自动化部署脚本，可以从Docker安装到服务启动的全流程自动化部署。

#### 脚本功能
- ✅ 自动检测操作系统类型
- ✅ 自动安装Docker和相关依赖
- ✅ 自动配置Docker服务和用户权限
- ✅ 自动检测并安装NVIDIA Docker（GPU支持）
- ✅ 自动构建Voice Changer Better镜像
- ✅ 自动创建并启动容器
- ✅ 自动验证部署状态

#### 使用方法

1. **克隆项目**
```bash
# 创建工作目录
mkdir -p ~/voice-changer
cd ~/voice-changer

# 克隆项目
git clone https://github.com/Sakana-yuyu/voice-changer-better.git
cd voice-changer-better
```

2. **运行自动化部署脚本**
```bash
# 给脚本添加执行权限
chmod +x auto_deploy.sh

# 运行自动化部署
./auto_deploy.sh
```

3. **等待部署完成**
脚本会自动执行以下步骤：
- 检测系统环境
- 安装Docker和依赖
- 配置服务和权限
- 构建镜像
- 启动容器
- 验证部署

4. **访问服务**
部署完成后，您可以通过以下方式访问：
- **Web界面**: http://localhost:6006
- **API接口**: http://localhost:6006/api/hello

#### 脚本执行示例
```bash
$ ./auto_deploy.sh
======================================
Voice Changer Better 自动化部署脚本
======================================

[INFO] 检测操作系统...
[INFO] 检测到系统: Ubuntu 20.04.5 LTS
[INFO] 更新系统包...
[SUCCESS] 系统更新完成
[INFO] 安装基础依赖...
[SUCCESS] 基础依赖安装完成
[INFO] 检查Docker安装状态...
[INFO] Docker未安装，开始安装...
[SUCCESS] Docker安装完成
[SUCCESS] Docker服务已启动并设置为开机自启
[SUCCESS] 用户权限配置完成
[SUCCESS] Docker安装验证成功
[INFO] 检测到NVIDIA GPU，安装NVIDIA Docker支持...
[SUCCESS] NVIDIA Docker安装完成
[SUCCESS] 项目目录准备完成
[INFO] 开始构建镜像，这可能需要几分钟时间...
[SUCCESS] Docker镜像构建完成
[INFO] 启动GPU版本容器...
[SUCCESS] 容器启动完成
[SUCCESS] 服务启动成功！
[SUCCESS] 部署验证完成！

访问信息:
  Web界面: http://localhost:6006
  API接口: http://localhost:6006/api/hello

🎉 Voice Changer Better 部署完成！
```

#### 注意事项
- 脚本需要sudo权限来安装系统包和配置Docker
- 首次运行可能需要10-30分钟（取决于网络速度）
- 如果遇到网络问题，脚本会自动重试或提供解决方案
- 脚本支持Ubuntu/Debian/CentOS等主流Linux发行版

#### 故障排除
如果自动化脚本遇到问题，您可以：
1. 查看脚本输出的错误信息
2. 使用下面的手动部署方法
3. 在GitHub仓库中提交Issue

---

## 📖 手动部署指南

**如果您希望了解详细的部署过程或自动化脚本遇到问题，可以按照以下手动步骤进行部署。**

## 🚀 第一步：环境准备

### 1.1 更新系统
```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

### 1.2 安装Docker

**Ubuntu/Debian:**
```bash
# 卸载旧版本
sudo apt-get remove docker docker-engine docker.io containerd runc

# 安装依赖
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加Docker仓库
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```

**CentOS/RHEL:**
```bash
# 卸载旧版本
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# 安装yum-utils
sudo yum install -y yum-utils

# 添加Docker仓库
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装Docker Engine
sudo yum install -y docker-ce docker-ce-cli containerd.io
```

### 1.3 启动Docker服务
```bash
# 启动Docker
sudo systemctl start docker

# 设置开机自启
sudo systemctl enable docker

# 验证安装
sudo docker run hello-world

# 将当前用户添加到docker组（可选）
sudo usermod -aG docker $USER
# 注意：需要重新登录才能生效
```

### 1.4 安装Docker Compose
```bash
# 下载Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

### 1.5 安装NVIDIA Docker（GPU版本需要）

**如果您有NVIDIA GPU并希望使用GPU加速，请执行以下步骤：**

```bash
# 安装NVIDIA驱动（如果尚未安装）
# Ubuntu
sudo apt install -y nvidia-driver-470

# 添加NVIDIA Docker仓库
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# 安装nvidia-docker2
sudo apt-get update
sudo apt-get install -y nvidia-docker2

# 重启Docker服务
sudo systemctl restart docker

# 测试GPU支持
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

## 📦 第二步：克隆项目

### 2.1 安装Git（如果尚未安装）
```bash
# Ubuntu/Debian
sudo apt install -y git

# CentOS/RHEL
sudo yum install -y git
```

### 2.2 克隆项目仓库
```bash
# 创建工作目录
mkdir -p ~/voice-changer
cd ~/voice-changer

# 克隆项目
git clone https://github.com/Sakana-yuyu/voice-changer-better.git
cd voice-changer-better

# 查看项目结构
ls -la
```

### 2.3 创建必要的目录
```bash
# 创建模型和数据目录
mkdir -p models
mkdir -p pretrain
mkdir -p tmp

# 设置目录权限
chmod 755 models pretrain tmp
```

## 🐳 第三步：Docker部署

### 3.1 构建Docker镜像
```bash
# 确保在项目根目录
pwd  # 应该显示 .../voice-changer-better

# 构建镜像（这可能需要10-30分钟）
docker build -t voice-changer-better:latest .

# 查看构建的镜像
docker images | grep voice-changer-better
```

### 3.2 运行容器

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
  --restart unless-stopped \
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
  --restart unless-stopped \
  voice-changer-better:latest
```

### 3.3 验证部署
```bash
# 检查容器状态
docker ps | grep voice-changer-better

# 查看容器日志
docker logs -f voice-changer-better

# 测试API接口
curl http://localhost:6006/api/hello

# 检查健康状态
docker inspect --format='{{.State.Health.Status}}' voice-changer-better
```

## 🌐 第四步：访问和使用

### 4.1 访问Web界面
1. 打开浏览器
2. 访问：http://your-server-ip:6006
3. 如果是本地部署，访问：http://localhost:6006

### 4.2 上传模型文件
```bash
# 将模型文件复制到models目录
cp /path/to/your/model.pth ~/voice-changer/voice-changer-better/models/

# 将预训练文件复制到pretrain目录
cp /path/to/pretrain/*.pth ~/voice-changer/voice-changer-better/pretrain/
cp /path/to/pretrain/*.onnx ~/voice-changer/voice-changer-better/pretrain/

# 重启容器以加载新模型
docker restart voice-changer-better
```

### 4.3 配置防火墙（如果需要）
```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 6006/tcp
sudo ufw reload

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=6006/tcp
sudo firewall-cmd --reload

# 或者直接使用iptables
sudo iptables -A INPUT -p tcp --dport 6006 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
```

## 🔧 第五步：服务管理

### 5.1 常用管理命令
```bash
# 查看容器状态
docker ps -a | grep voice-changer

# 启动容器
docker start voice-changer-better

# 停止容器
docker stop voice-changer-better

# 重启容器
docker restart voice-changer-better

# 查看实时日志
docker logs -f voice-changer-better

# 进入容器调试
docker exec -it voice-changer-better bash

# 删除容器
docker rm voice-changer-better

# 删除镜像
docker rmi voice-changer-better:latest
```

### 5.2 设置开机自启
```bash
# 容器已经设置了 --restart unless-stopped
# Docker服务开机自启
sudo systemctl enable docker

# 验证设置
sudo systemctl is-enabled docker
```

### 5.3 备份和恢复
```bash
# 备份模型和配置
tar -czf voice-changer-backup-$(date +%Y%m%d).tar.gz models/ pretrain/ tmp/

# 恢复备份
tar -xzf voice-changer-backup-20231201.tar.gz
```

## 🛠️ 故障排除

### 6.1 常见问题

**问题1：容器无法启动**
```bash
# 检查Docker服务状态
sudo systemctl status docker

# 检查端口占用
sudo netstat -tlnp | grep 6006

# 查看详细错误日志
docker logs voice-changer-better

# 检查磁盘空间
df -h
```

**问题2：GPU不可用**
```bash
# 检查NVIDIA驱动
nvidia-smi

# 检查NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# 重新安装nvidia-docker2
sudo apt-get purge nvidia-docker2
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

**问题3：权限问题**
```bash
# 检查目录权限
ls -la models/ pretrain/ tmp/

# 修复权限
sudo chown -R $(id -u):$(id -g) models/ pretrain/ tmp/
chmod -R 755 models/ pretrain/ tmp/
```

**问题4：网络连接问题**
```bash
# 检查防火墙状态
sudo ufw status  # Ubuntu
sudo firewall-cmd --list-all  # CentOS

# 检查端口监听
sudo netstat -tlnp | grep 6006

# 测试本地连接
curl -v http://localhost:6006/api/hello
```

### 6.2 性能优化

**增加共享内存：**
```bash
docker run -d \
  --name voice-changer-better \
  --gpus all \
  --shm-size=2g \
  -p 6006:6006 \
  # ... 其他参数
  voice-changer-better:latest
```

**限制资源使用：**
```bash
docker run -d \
  --name voice-changer-better \
  --gpus all \
  --memory=8g \
  --cpus=4 \
  -p 6006:6006 \
  # ... 其他参数
  voice-changer-better:latest
```

## 📝 第六步：验证部署成功

### 6.1 完整测试流程
```bash
# 1. 检查容器运行状态
docker ps | grep voice-changer-better
# 应该显示容器正在运行

# 2. 测试API响应
curl http://localhost:6006/api/hello
# 应该返回JSON响应

# 3. 检查健康状态
docker inspect --format='{{.State.Health.Status}}' voice-changer-better
# 应该显示 "healthy"

# 4. 访问Web界面
# 在浏览器中打开 http://localhost:6006
# 应该看到Voice Changer界面

# 5. 检查日志无错误
docker logs voice-changer-better | tail -20
# 应该看到服务启动成功的日志
```

### 6.2 成功标志
✅ 容器状态为 "Up"
✅ API接口返回正常响应
✅ 健康检查状态为 "healthy"
✅ Web界面可以正常访问
✅ 日志中无严重错误信息

## 🎉 部署完成！

恭喜！您已经成功在Linux系统上部署了Voice Changer Better项目。

### 下一步操作：
1. 上传您的语音模型文件到 `models/` 目录
2. 在Web界面中选择模型
3. 开始使用实时语音变声功能

### 获取帮助：
- 项目文档：查看项目根目录下的README.md
- 问题反馈：在GitHub仓库中提交Issue
- 社区支持：加入相关技术交流群

---

**注意事项：**
- 定期备份重要的模型文件
- 监控系统资源使用情况
- 及时更新Docker镜像版本
- 保持系统和驱动程序最新