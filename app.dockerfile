ARG PARENT_TAG="peterts/mlflow-test-env:latest"
FROM $PARENT_TAG

WORKDIR /opt
COPY mlflow_test /opt/project/mlflow_test