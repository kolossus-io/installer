default: help
VERSION_TAG=0.2.0
TERRAFORM_VER=0.11.8
TECTONIC_INSTALLER=1.9.6-tectonic.1

build: ## Build the docker image for the installer
	@-docker rmi kolossus-installer:$(VERSION_TAG)
	docker build \
		--build-arg VERSION_TAG="$(VERSION_TAG)" \
		--build-arg TERRAFORM_VER="$(TERRAFORM_VER)" \
		--build-arg TECTONIC_INSTALLER="$(TECTONIC_INSTALLER)" \
		--rm -t kolossus-installer:$(VERSION_TAG) .

version: ## Display installer version information
	docker run -it --rm kolossus-installer:$(VERSION_TAG) version

run: ## Execute installer function; action=(start, resize, destroy)
	docker run -it --rm \
	-v `pwd`/clusters/$(target)/backend.tf.json:/installer/platforms/aws/backend.tf.json \
	-v `pwd`/clusters/$(target)/user.tfvars.json:/user.tfvars.json \
	-v `pwd`/clusters/$(target)/output:/output \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e AWS_REGION=$(AWS_REGION) \
	kolossus-installer:$(VERSION_TAG) $(action)

start: ## Perform a new cluster installation
	make run action=start target=$(target)

resize: ## Resize an existing cluster
	make run action=resize target=$(target)

destroy: ## Destroy an existing cluster
	make run action=destroy target=$(target)
	rm -rf `pwd`/clusters/$(target)/output

help: ## Display available make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%-16s\033[0m %s\n", $$1, $$2}'
