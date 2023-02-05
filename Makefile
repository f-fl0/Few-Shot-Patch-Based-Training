DOCKER_CMD       = DOCKER_BUILDKIT=1 docker
DOCKER_BUILD_CMD = $(DOCKER_CMD) build --pull=true --progress=plain
IMAGE_NAME       = video-stylization

.PHONY: docker-image
docker-image:
	$(DOCKER_BUILD_CMD) -t $(IMAGE_NAME) .
