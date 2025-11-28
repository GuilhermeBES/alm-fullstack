.PHONY: all build up down logs clean

all: up

build:
	docker compose build

up: build
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

clean:
	docker compose down --volumes --rmi all

rebuild: clean build up
