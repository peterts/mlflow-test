ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PROJECT_DIR	:= $(ROOT_DIR).
ENV_IMAGE_NAME := peterts/mlflow-test-env
ENV_IMAGE_DOCKERFILE := $(PROJECT_DIR)/env.dockerfile
APP_IMAGE_NAME := peterts/mlflow-test
APP_IMAGE_DOCKERFILE := $(PROJECT_DIR)/app.dockerfile
MLFLOW_SERVER_PORT := 5000
MLFLOW_OUTPUT_DIR := mlflow
DOCKER_PROJECT_DIR := /opt/project


.PHONY: build-env build-app mlflow-dir server shell train


all: build-app


build-env:
	docker build \
	-t $(ENV_IMAGE_NAME):latest \
	-f $(ENV_IMAGE_DOCKERFILE) \
	$(PROJECT_DIR)


build-app: build-env
	docker build \
	--build-arg PARENT_TAG=$(ENV_IMAGE_NAME):latest \
	-t $(APP_IMAGE_NAME):latest \
	-f $(APP_IMAGE_DOCKERFILE) \
	$(PROJECT_DIR)


mlflow-dir:
	IF exist "$(PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR)" ( echo "$(PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR)" exists ) ELSE ( mkdir "$(PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR)" )


shell: build-app mlflow-dir
	docker run -it --rm --init -w="$(DOCKER_PROJECT_DIR)/mlflow_test" \
	-v $(PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR):$(DOCKER_PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR) \
	$(APP_IMAGE_NAME):latest


server: build-app mlflow-dir
	docker run \
	-it --rm --init -w="$(DOCKER_PROJECT_DIR)/mlflow_test" -p $(MLFLOW_SERVER_PORT):5000 \
	-v $(PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR):$(DOCKER_PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR) \
	$(APP_IMAGE_NAME):latest  \
	mlflow server \
	--host 0.0.0.0 \
	--file-store $(DOCKER_PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR)/files \
	--default-artifact-root $(DOCKER_PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR)/artifacts



train: build-app
	docker run \
	-v $(PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR):$(DOCKER_PROJECT_DIR)/$(MLFLOW_OUTPUT_DIR) \
	-v $(PROJECT_DIR)/data:/opt/project/data \
	-e MLFLOW_TRACKING_URI="http://docker.for.win.localhost:$(MLFLOW_SERVER_PORT)" \
	-it --rm --init -w="$(DOCKER_PROJECT_DIR)/mlflow_test" \
	$(APP_IMAGE_NAME):latest python train.py $(TRAIN_ARGS)