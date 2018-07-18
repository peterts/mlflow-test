ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PROJECT_DIR	:= $(ROOT_DIR).

ENV_IMAGE_NAME 				:= peterts/mlflow-test-env
ENV_IMAGE_DOCKERFILE		:= $(PROJECT_DIR)/env.dockerfile

APP_IMAGE_NAME 				:= peterts/mlflow-test
APP_IMAGE_DOCKERFILE		:= $(PROJECT_DIR)/app.dockerfile

.PHONY: build-env build-app notebooks


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


shell: build-app
	docker run -v $(PROJECT_DIR)/mlflow_test/mlruns:/opt/project/mlflow_test/mlruns \
	-it --rm --init -w="/opt/project/mlflow_test" \
	$(APP_IMAGE_NAME):latest


mlflow-ui: build-app
	docker run -v $(PROJECT_DIR)/mlflow_test/mlruns:/opt/project/mlflow_test/mlruns \
	-it --rm --init -w="/opt/project/mlflow_test" -p 5000:5000 \
	$(APP_IMAGE_NAME):latest mlflow ui --host 0.0.0.0


run-train:
	docker run -v $(PROJECT_DIR)/mlflow_test/mlruns:/opt/project/mlflow_test/mlruns \
	-v $(PROJECT_DIR)/data:/opt/project/data \
	-it --rm --init -w="/opt/project/mlflow_test" \
	$(APP_IMAGE_NAME):latest python train.py $(TRAIN_ARGS)