
all: docker-load jenkins

cluster:
	@$(call check_req,k3d)
## Create cluster if it does not already exist
	@if k3d cluster list  --no-headers | grep -q '^$(CLUSTER_NAME) '; then k3d cluster start jenkins; else \
		k3d cluster create \
		--port="80:80@loadbalancer" \
		--port="443:443@loadbalancer" \
		--port="3000:3000@loadbalancer" \
		$(CLUSTER_NAME); fi;
	@echo "== The k3d cluster named '$(CLUSTER_NAME)' is ready."

jenkins: cluster
	@$(call check_req,helmfile)
	@helm diff --help > /dev/null 2>&1 || { echo "ERROR: You need to install the helm plugin 'diff'"; exit 1 ; }
	@helmfile apply

clean: clean-jenkins clean-cluster

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
	@docker build --tag=$(DOCKER_IMAGE_NAME) $(CURDIR)/../docker-image/

docker-load: docker cluster
	@k3d image import --cluster=jenkins $(DOCKER_IMAGE_NAME)

.PHONY: all cluster clean jenkins clean-jenkins clean-cluster docker docker-load

## Common variables
CLUSTER_NAME ?= jenkins
DOCKER_IMAGE_NAME ?= dduportal/jenkins-k8s

## Reusable Macros
check_req = command -v "$(1)" > /dev/null 2>&1 || { echo "You need to install the '$(1)' command" ; exit 1 ; }
