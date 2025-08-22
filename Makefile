# Makefile for Jupyter Notebook Server with Docker Hub integration

# Variables - customize these for your setup
DOCKER_USERNAME ?= metythorn
IMAGE_NAME ?= jupyter
TAG ?= latest
FULL_IMAGE_NAME = $(DOCKER_USERNAME)/$(IMAGE_NAME):$(TAG)
LOCAL_IMAGE_NAME = local/$(IMAGE_NAME):$(TAG)
CONTAINER_NAME = jupyter-server-5369
HOST_PORT = 5369
CONTAINER_PORT = 8888

# Help target - shows available commands
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  build         - Build the Docker image locally"
	@echo "  build-hub     - Build and tag image for Docker Hub"
	@echo "  push          - Push image to Docker Hub (requires login)"
	@echo "  pull          - Pull image from Docker Hub"
	@echo "  run           - Run container from local image"
	@echo "  run-hub       - Run container from Docker Hub image"
	@echo "  stop          - Stop the running container"
	@echo "  restart       - Restart the container"
	@echo "  logs          - Show container logs"
	@echo "  shell         - Access container shell"
	@echo "  clean         - Remove container and local images"
	@echo "  login         - Login to Docker Hub"
	@echo "  compose-up    - Start services with docker-compose"
	@echo "  compose-down  - Stop services with docker-compose"
	@echo ""
	@echo "Configuration:"
	@echo "  DOCKER_USERNAME: $(DOCKER_USERNAME)"
	@echo "  IMAGE_NAME: $(IMAGE_NAME)"
	@echo "  TAG: $(TAG)"
	@echo "  FULL_IMAGE_NAME: $(FULL_IMAGE_NAME)"

# Build image locally
.PHONY: build
build:
	@echo "Building local Docker image: $(LOCAL_IMAGE_NAME)"
	docker build -t $(LOCAL_IMAGE_NAME) .
	@echo "Build completed: $(LOCAL_IMAGE_NAME)"

# Build and tag for Docker Hub
.PHONY: build-hub
build-hub:
	@echo "Building Docker image for Docker Hub: $(FULL_IMAGE_NAME)"
	docker build -t $(LOCAL_IMAGE_NAME) -t $(FULL_IMAGE_NAME) .
	@echo "Build completed: $(FULL_IMAGE_NAME)"

# Login to Docker Hub
.PHONY: login
login:
	@echo "Logging into Docker Hub..."
	docker login

# Push to Docker Hub
.PHONY: push
push: build-hub
	@echo "Pushing $(FULL_IMAGE_NAME) to Docker Hub..."
	docker push $(FULL_IMAGE_NAME)
	@echo "Push completed: $(FULL_IMAGE_NAME)"

# Pull from Docker Hub
.PHONY: pull
pull:
	@echo "Pulling $(FULL_IMAGE_NAME) from Docker Hub..."
	docker pull $(FULL_IMAGE_NAME)
	@echo "Pull completed: $(FULL_IMAGE_NAME)"

# Run container from local image
.PHONY: run
run:
	@echo "Running container from local image: $(LOCAL_IMAGE_NAME)"
	docker run -d \
		--name $(CONTAINER_NAME) \
		--runtime=nvidia \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		-v $(PWD)/volumes:/home/jovyan/work \
		-e JUPYTER_PASSWORD="96$$sweQ$$schlategeLsRas7003" \
		-e NVIDIA_VISIBLE_DEVICES=all \
		-e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
		--restart unless-stopped \
		$(LOCAL_IMAGE_NAME)
	@echo "Container started: $(CONTAINER_NAME)"
	@echo "Access Jupyter at: http://localhost:$(HOST_PORT)"

# Run container from Docker Hub image
.PHONY: run-hub
run-hub:
	@echo "Running container from Docker Hub image: $(FULL_IMAGE_NAME)"
	docker run -d \
		--name $(CONTAINER_NAME) \
		--runtime=nvidia \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		-v $(PWD)/volumes:/home/jovyan/work \
		-e JUPYTER_PASSWORD="96$$sweQ$$schlategeLsRas7003" \
		-e NVIDIA_VISIBLE_DEVICES=all \
		-e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
		--restart unless-stopped \
		$(FULL_IMAGE_NAME)
	@echo "Container started: $(CONTAINER_NAME)"
	@echo "Access Jupyter at: http://localhost:$(HOST_PORT)"

# Stop container
.PHONY: stop
stop:
	@echo "Stopping container: $(CONTAINER_NAME)"
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	@echo "Container stopped and removed"

# Restart container
.PHONY: restart
restart: stop run

# Show container logs
.PHONY: logs
logs:
	@echo "Showing logs for container: $(CONTAINER_NAME)"
	docker logs -f $(CONTAINER_NAME)

# Access container shell
.PHONY: shell
shell:
	@echo "Accessing shell in container: $(CONTAINER_NAME)"
	docker exec -it $(CONTAINER_NAME) /bin/bash

# Clean up - remove container and images
.PHONY: clean
clean:
	@echo "Cleaning up containers and images..."
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	-docker rmi $(LOCAL_IMAGE_NAME)
	-docker rmi $(FULL_IMAGE_NAME)
	@echo "Cleanup completed"

# Docker Compose commands
.PHONY: compose-up
compose-up:
	@echo "Starting services with docker-compose..."
	docker-compose up -d
	@echo "Services started. Access Jupyter at: http://localhost:5369"

.PHONY: compose-down
compose-down:
	@echo "Stopping services with docker-compose..."
	docker-compose down
	@echo "Services stopped"

# Utility commands
.PHONY: status
status:
	@echo "Container status:"
	-docker ps -a --filter name=$(CONTAINER_NAME)
	@echo ""
	@echo "Image status:"
	-docker images | grep -E "($(IMAGE_NAME)|$(DOCKER_USERNAME))"

# Build and push in one command
.PHONY: deploy
deploy: build-hub push
	@echo "Image built and pushed to Docker Hub: $(FULL_IMAGE_NAME)"

# Quick development setup
.PHONY: dev
dev: build run
	@echo "Development environment ready!"
	@echo "Access Jupyter at: http://localhost:$(HOST_PORT)"
	@echo "Password: 96$$sweQ$$schlategeLsRas7003"