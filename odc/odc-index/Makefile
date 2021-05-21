IMG ?= odc-index:latest
base ?= latest
dkr_cache ?= dkr_cache

dkr:
	DOCKER_BUILDKIT=1 docker build \
    --build-arg V_BASE=$(base) \
    --cache-from type=local,src=$(dkr_cache) \
    -t $(IMG) .

bash:
	docker run --rm -ti $(IMG) bash
