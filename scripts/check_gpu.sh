#!/usr/bin/env bash
set -euo pipefail

command -v nvidia-smi >/dev/null || {
  echo "未找到 nvidia-smi：请先安装 NVIDIA 驱动。" >&2
  exit 1
}
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv

if ! docker info >/dev/null 2>&1; then
  echo "Docker 不可用，请先启动 Docker。" >&2
  exit 1
fi

docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi >/dev/null && \
  echo "Docker 已能访问 GPU。"
