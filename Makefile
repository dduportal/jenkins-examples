
all: docker-load jenkins

cluster:
	@$(call check_req,k3d)
## Create cluster if it does not already exist
	@if k3d cluster list  --no-headers | grep -q '^$(CLUSTER_NAME) '; then k3d cluster start jenkins; else \
		k3d cluster create \
		--port="80:80@loadbalancer" \
		--port="443:443@loadbalancer" \
		$(CLUSTER_NAME); fi;
	@echo "== The k3d cluster named '$(CLUSTER_NAME)' is ready."

jenkins: cluster
	@$(call check_req,helmfile)
	@helmfile apply

clean: clean-jenkins clean-cluster
	rm -f ./docker-image.tar

clean-jenkins:
	@$(call check_req,helmfile)
	@$(call check_req,kubectl)
	@helmfile destroy
	@kubectl delete namespace jenkins || true

clean-cluster:
	@$(call check_req,k3d)
	@k3d cluster delete $(CLUSTER_NAME)
	@echo "== The k3d cluster named '$(CLUSTER_NAME)' does not exist anymore.."

docker:
	@docker build --tag=$(DOCKER_IMAGE_NAME) ./docker/

docker-image.tar: | docker
	@docker save $(DOCKER_IMAGE_NAME) --output=./docker-image.tar

docker-load: docker-image.tar cluster
	@k3d image import --cluster=jenkins ./docker-image.tar

UPGRADE_PLUGINS ?= false
plugins: docker
	@bash ./docker/plugins.sh $(DOCKER_IMAGE_NAME) $(UPGRADE_PLUGINS)

.PHONY: all cluster clean jenkins clean-jenkins clean-cluster plugins docker docker-load

## Common variables
CLUSTER_NAME ?= jenkins
DOCKER_IMAGE_NAME ?= dduportal/jenkins-k8s

## Reusable Macros
check_req = command -v "$(1)" > /dev/null 2>&1 || { echo "You need to install the '$(1)' command" ; exit 1 ; }
