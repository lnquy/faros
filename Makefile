PROJECT_NAME = faros
DOCKER_IMAGE_VERSION = 0.0.1
FAROS_CONTAINER_PORT = 9999
FAROS_NODE_PORT = 31001
K8S_DIR = misc/kubernetes

BUILD_TIME := $(shell TZ='UTC' date --rfc-3339 seconds)


all: go_build docker_build

go_build: clean
	CGO_ENABLED=0 go build -o ${PROJECT_NAME} main.go

docker_build:
	echo Building Docker image at: $(BUILD_TIME)
	docker build -t lnquy/faros:${DOCKER_IMAGE_VERSION} .

docker_run:
	docker run --rm -p ${FAROS_PORT}:${FAROS_PORT} lnquy/faros:${DOCKER_IMAGE_VERSION}

docker: docker_build docker_run

clean: minikube_clean
	rm -f ${PROJECT_NAME}


# Local development with minikube
minikube_env:
	eval $(minikube docker-env)

k8s_gen_file:
	sed 's/@IMAGE_VERSION/${DOCKER_IMAGE_VERSION}/g' ${K8S_DIR}/faros.yaml > ${K8S_DIR}/faros.yaml.dep
	sed -i 's/@CONTAINER_PORT/${FAROS_CONTAINER_PORT}/g' ${K8S_DIR}/faros.yaml.dep
	sed -i 's/@NODE_PORT/${FAROS_NODE_PORT}/g' ${K8S_DIR}/faros.yaml.dep

minikube_deploy:
	kubectl config use-context minikube
	kubectl delete deploy,svc faros | true
	kubectl create -f ${K8S_DIR}/faros.yaml.dep

minikube_clean:
	rm -f ${K8S_DIR}/faros.yaml.dep

minikube: minikube_clean clean go_build minikube_env docker_build k8s_gen_file minikube_deploy


.PHONY:
	all \
	go_build \
	docker_build \
	docker_run \
	docker \
	clean \
	minikube_env \
	k8s_gen_file \
	minikube_deploy \
	minikube_clean \
	minikube
