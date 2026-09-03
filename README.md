# personal-private-llm-stack

个人私有本地化大模型部署栈：在自己的 GPU/服务器上运行可替换的开源模型，通过局域网提供统一的 OpenAI-compatible API，供其他电脑、脚本、IDE、Codex 或协议适配层调用。

模型不是项目的一部分，而是 `.env` 中的配置项。默认值仅作为 24GB 显存的示例，复制仓库后可以替换为其他 Hugging Face 模型或本地模型目录。

## 上传到 GitHub

建议 GitHub 仓库名使用 `personal-private-llm-stack`。在 GitHub 新建一个空仓库后执行：

```bash
cd personal-private-llm-stack
git init
git add .
git commit -m "Initial private local LLM deployment stack"
git branch -M main
git remote add origin git@github.com:你的用户名/personal-private-llm-stack.git
git push -u origin main
```

`.env`、模型缓存和本地模型目录已加入 `.gitignore`，不会被提交。

这个目录是一个最小可维护部署框架：当前使用 vLLM 作为推理后端，但后续可以替换为其他后端；另一台电脑通过局域网调用 `http://服务器IP:8000/v1`。

## 推荐模型

默认使用 `Qwen/Qwen3-8B` 作为示例。你可以把 `MODEL_NAME` 改成 Llama、Mistral、DeepSeek、Qwen 或其他 vLLM 支持的模型。模型大小、量化方式、上下文长度需要根据自己的显存重新评估；24GB 显存下建议从 7B/8B 或 4-bit 量化模型开始。

## 启动

要求：NVIDIA 驱动、Docker、Docker Compose v2、NVIDIA Container Toolkit。

```bash
cp .env.example .env
# 编辑 .env，至少修改 VLLM_API_KEY；确认 MODEL_NAME
make setup
./scripts/check_gpu.sh
make up
make logs
```

首次启动会下载模型到 `data/huggingface`，之后重启会复用缓存。查看服务：

```bash
curl http://127.0.0.1:8000/v1/models \
  -H "Authorization: Bearer 你的VLLM_API_KEY"
```

## 从另一台电脑调用

先确认两台电脑在同一局域网，并在服务器防火墙只放行可信网段的 TCP 8000。把下面的 `SERVER_IP` 和 API key 换成实际值：

```bash
curl http://SERVER_IP:8000/v1/chat/completions \
  -H "Authorization: Bearer 你的VLLM_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"你的模型ID","messages":[{"role":"user","content":"你好"}]}'
```

`model` 字段必须使用 `/v1/models` 返回的模型 ID；如果 `MODEL_NAME` 配置的是本地路径，这个 ID 可能就是该路径。

Python 客户端：

```bash
pip install openai
export VLLM_BASE_URL=http://SERVER_IP:8000/v1
export VLLM_API_KEY=你的VLLM_API_KEY
export VLLM_MODEL=你在/v1/models中看到的模型ID
python scripts/chat.py
```

## Claude Code / Codex 的边界

这个服务原生是 OpenAI-compatible API，因此任何支持自定义 `base_url` 的 OpenAI 客户端、Codex CLI 或 IDE 插件都可以按上面的地址配置。不同版本的 Codex CLI 环境变量名称可能不同，请以该版本的 `--help` 为准。

Claude Code 通常期待 Anthropic Messages API，不一定能直接使用 vLLM 的 `/v1/chat/completions`。若必须让 Claude Code 调用本地模型，应在两者之间增加 LiteLLM 等协议适配层，并把 Claude Code 指向适配层；这属于第二阶段，先验证 vLLM API 可用更稳妥。

## 常见调整

- 显存不足：把 `VLLM_MAX_MODEL_LEN` 降到 4096，或把 `VLLM_MAX_NUM_SEQS` 降到 1/2。
- 想要更长上下文：先观察 `nvidia-smi`，逐步增加 `VLLM_MAX_MODEL_LEN`，不要同时提高并发。
- 使用本地模型：把模型放进 `models/`，在 compose 中挂载 `./models:/models:ro`，并将 `MODEL_NAME` 设为容器内路径（如 `/models/Qwen3-8B`）。
- 生产环境：不要把 8000 端口暴露到公网；需要公网访问时加 VPN、反向代理和 TLS。
