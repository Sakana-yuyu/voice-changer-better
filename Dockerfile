# 多阶段构建 - Voice Changer Better
# Stage 1: 构建前端应用
FROM node:18-alpine AS frontend-builder

WORKDIR /app

# 复制前端相关文件
COPY client/lib/package*.json ./client/lib/
COPY client/demo/package*.json ./client/demo/

# 安装依赖（包含开发依赖，构建时需要）
RUN cd client/lib && npm ci
RUN cd client/demo && npm ci

# 复制源代码
COPY client/ ./client/

# 构建前端
RUN cd client/lib && npm run build:prod
RUN cd client/demo && npm run build:prod

# Stage 2: Python后端环境
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 AS backend-base

ARG DEBIAN_FRONTEND=noninteractive

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    python3-venv \
    git \
    espeak \
    gosu \
    libsndfile1-dev \
    emacs \
    curl \
    build-essential \
    pkg-config \
    libffi-dev \
    libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /voice-changer

# 复制requirements文件
COPY server/requirements.txt ./server/

# 升级pip和安装基础工具
RUN pip3 install --upgrade pip setuptools wheel

# 先安装PyTorch相关依赖（可能需要特定的CUDA版本）
RUN pip3 install --no-cache-dir torch==2.0.1 torchaudio==2.0.2 --index-url https://download.pytorch.org/whl/cu118

# 安装其他Python依赖
RUN pip3 install --no-cache-dir -r server/requirements.txt || \
    (echo "依赖安装失败，尝试逐个安装..." && \
     pip3 install --no-cache-dir uvicorn==0.21.1 && \
     pip3 install --no-cache-dir pyOpenSSL==23.1.1 && \
     pip3 install --no-cache-dir numpy==1.23.5 && \
     pip3 install --no-cache-dir resampy==0.4.2 && \
     pip3 install --no-cache-dir python-socketio==5.8.0 && \
     pip3 install --no-cache-dir fastapi==0.95.1 && \
     pip3 install --no-cache-dir python-multipart==0.0.6 && \
     pip3 install --no-cache-dir onnxruntime-gpu==1.13.1 && \
     pip3 install --no-cache-dir scipy==1.10.1 && \
     pip3 install --no-cache-dir matplotlib==3.7.1 && \
     pip3 install --no-cache-dir websockets==11.0.2 && \
     pip3 install --no-cache-dir faiss-cpu==1.7.3 && \
     pip3 install --no-cache-dir torchcrepe==0.0.18 && \
     pip3 install --no-cache-dir librosa==0.9.1 && \
     pip3 install --no-cache-dir gin==0.1.6 && \
     pip3 install --no-cache-dir gin_config==0.5.0 && \
     pip3 install --no-cache-dir einops==0.6.0 && \
     pip3 install --no-cache-dir local_attention==1.8.5 && \
     pip3 install --no-cache-dir sounddevice==0.4.6 && \
     pip3 install --no-cache-dir dataclasses_json==0.5.7 && \
     pip3 install --no-cache-dir onnxsim==0.4.28 && \
     pip3 install --no-cache-dir torchfcpe==0.0.3)

# Stage 3: 最终镜像
FROM backend-base AS final

# 复制后端代码
COPY server/ ./server/

# 复制前端构建结果
COPY --from=frontend-builder /app/client/demo/dist ./server/static/

# 复制Docker脚本
COPY docker/setup.sh ./server/
COPY docker/exec.sh ./server/

# 设置权限
RUN chmod +x ./server/setup.sh ./server/exec.sh
RUN chmod 0777 ./server

# 创建用户目录
RUN mkdir -p /resources /voice-changer/server/model_dir /voice-changer/server/tmp_dir
RUN chmod 0777 /resources /voice-changer/server/model_dir /voice-changer/server/tmp_dir

# 设置工作目录
WORKDIR /voice-changer/server

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:18888/api/hello || exit 1

# 暴露端口
EXPOSE 18888

# 入口点
ENTRYPOINT ["/bin/bash", "setup.sh"]
CMD ["MMVC", "-p", "18888", "--https", "false"]