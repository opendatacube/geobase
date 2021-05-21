IMG ?= odc-index:latest
base ?= latest
dkr_cache ?= dkr_cache
progress ?= auto

dkr:
	DOCKER_BUILDKIT=1 docker build \
    --progress $(progress) \
    --build-arg V_BASE=$(base) \
    -t $(IMG) .

bash:
	docker run --rm -ti -v $$(pwd):/wk $(IMG) bash
