
all: jenkins

cluster:
	@$(call check_req,k3d)
## Create cluster if it does not already exist
	@if k3d cluster list  --no-headers | grep -q '^$(CLUSTER_NAME) '; then k3d cluster start jenkins; else \
		k3d cluster create \
		--port="80:80@loadbalancer" \
		--port="443:443@loadbalancer" \
		--agents=2 \
		$(CLUSTER_NAME); fi;
	@echo "== The k3d cluster named '$(CLUSTER_NAME)' is ready."

jenkins: cluster
	@$(call check_req,helmfile)
	@helmfile apply

clean: clean-jenkins clean-cluster

clean-jenkins:
	@$(call check_req,helmfile)
	@helmfile destroy

clean-cluster:
	@$(call check_req,k3d)
	@k3d cluster delete $(CLUSTER_NAME)
	@echo "== The k3d cluster named '$(CLUSTER_NAME)' does not exist anymore.."

.PHONY: all cluster clean jenkins clean-jenkins clean-cluster

## Common variables
CLUSTER_NAME ?= jenkins

## Reusable Macros
check_req = command -v "$(1)" > /dev/null 2>&1 || { echo "You need to install the '$(1)' command" ; exit 1 ; }
