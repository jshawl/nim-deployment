.PHONY: build build-dev worker test

build:
	docker build --tag app .

test:
	docker compose run --rm test

test-watch:
	docker compose run --rm test-watch

worker:
	docker compose run --rm worker
