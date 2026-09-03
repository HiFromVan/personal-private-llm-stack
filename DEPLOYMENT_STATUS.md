# 部署状态

最后更新：2026-09-03

## 当前目标

在本机部署私有编程模型，减少云端 Codex/API token 消耗。

## 已确定方案

- 模型：`Qwen/Qwen2.5-Coder-32B-Instruct-AWQ`
- 量化：AWQ 4-bit
- GPU：NVIDIA GeForce RTX 3090，24GB 显存
- 内存：32GB（建议后续升级到 64GB）
- 上下文：8192
- 并发：1
- 服务：vLLM OpenAI-compatible API

## 已完成

- GitHub 仓库：<https://github.com/HiFromVan/personal-private-llm-stack>
- `main` 分支已推送
- `.env` 已在本地生成，包含随机 API key；该文件被 `.gitignore` 排除，不会上传
- `.env.example` 和 README 已更新为 Qwen 32B 配置

## 待完成

当前系统尚未安装或启用：

1. NVIDIA 驱动（需要 `nvidia-smi` 可用）
2. Docker Engine / Docker Compose
3. NVIDIA Container Toolkit
4. 运行 `make up`，首次下载约 20GB 的模型文件

验证 GPU 容器：

```bash
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

启动服务：

```bash
make up
make logs
```
