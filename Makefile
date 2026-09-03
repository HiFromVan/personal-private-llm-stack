.PHONY: setup up down logs ps test

setup:
	@test -f .env || cp .env.example .env
	@mkdir -p data/huggingface
	@echo "已生成 .env（请检查 MODEL_NAME 和 VLLM_API_KEY）"

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f vllm

ps:
	docker compose ps

test:
	@test -f .env || (echo "缺少 .env，请先执行 make setup"; exit 1)
	@set -a; . ./.env; set +a; \
	curl -fsS http://localhost:8000/v1/models \
		-H "Authorization: Bearer $$VLLM_API_KEY"
