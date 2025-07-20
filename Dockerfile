# 多阶段构建 - Voice Changer Better
# Stage 1: 构建前端应用
FROM node:18-alpine AS frontend-builder

WORKDIR /app

# 复制前端相关文件
COPY client/lib/package*.json ./client/lib/
COPY client/demo/package*.json ./client/demo/

# 安装依赖
RUN cd client/lib && npm ci --only=production
RUN cd client/demo && npm ci --only=production

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
    git \
    espeak \
    gosu \
    libsndfile1-dev \
    emacs \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /voice-changer

# 复制requirements文件
COPY server/requirements.txt ./server/

# 安装Python依赖
RUN pip3 install --no-cache-dir -r server/requirements.txt

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