#!/usr/bin/env python3
"""最小 OpenAI-compatible 客户端示例。"""
import os
from openai import OpenAI

client = OpenAI(
    base_url=os.getenv("VLLM_BASE_URL", "http://127.0.0.1:8000/v1"),
    api_key=os.environ["VLLM_API_KEY"],
)
model = os.environ["VLLM_MODEL"]
response = client.chat.completions.create(
    model=model,
    messages=[{"role": "user", "content": "用一句话介绍你自己。"}],
    temperature=0.2,
)
print(response.choices[0].message.content)
