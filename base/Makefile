ORG ?= opendatacube
TAG ?= latest

dkr: dkr_builder dkr_runner

dkr_builder:
	DOCKER_BUILDKIT=1 docker build \
   -f builder/Dockerfile \
   --build-arg BUILDKIT_INLINE_CACHE=1 \
   --cache-from $(ORG)/geobase-builder:latest \
   -t $(ORG)/geobase-builder:$(TAG) builder

dkr_runner: dkr_builder
	DOCKER_BUILDKIT=1 docker build \
    -f runner/Dockerfile \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from $(ORG)/geobase-runner:latest \
    --build-arg base=$(ORG)/geobase-builder:$(TAG) \
    -t $(ORG)/geobase-runner:$(TAG) runner

.PHONY: dkr dkr_builder dkr_runner
