lint-shellcheck:
	@docker compose run --rm lint-shellcheck

lint-plugin:
	@docker compose run --rm lint-plugin

lint: lint-plugin lint-shellcheck

test:
	@docker compose run --rm tests
	@echo "run 'make clean' to stop and remove test containers"

clean:
	@docker compose down

.DEFAULT_GOAL: test

.PHONY: lint test clean
.PHONY: lint-shellcheck lint-plugin