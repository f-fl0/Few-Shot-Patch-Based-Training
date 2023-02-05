#!/usr/bin/env bash

IMAGE_NAME=$(cat Makefile | grep -E ^IMAGE_NAME | cut -d= -f2 | awk '{$1=$1;print}')
IMAGE_TAG=latest

CONTAINER_NAME=${IMAGE_NAME/-/_}

DOCKER_ARGS_GUI=""
if [[ ${DISPLAY} ]]; then
  USER_XAUTH=${HOME}/.Xauthority
  XSOCK=/tmp/.X11-unix
  XAUTH=/tmp/.docker.xauth
  touch ${XAUTH}
  xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f ${XAUTH} nmerge -

  DOCKER_ARGS_GUI+="-e DISPLAY "
  DOCKER_ARGS_GUI+="-e XAUTHORITY=${XAUTH} "
  DOCKER_ARGS_GUI+="-v ${XAUTH}:${XAUTH}:rw "
  DOCKER_ARGS_GUI+="-v ${XSOCK}:${XSOCK}:rw "
else
  echo -e "\e[33m[WARN]: No display available.\e[0m"
fi

DOCKER_ARGS_GPU=""
if command -v nvidia-smi &> /dev/null; then
  gpu_list=$(nvidia-smi -L)
  if [[ ! -z $gpu_list ]]; then
    DOCKER_ARGS_GPU+="--gpus=all "
    DOCKER_ARGS_GPU+="-e NVIDIA_DRIVER_CAPABILITIES=all "
    DOCKER_ARGS_GPU+="-e CUDA_DEVICE_ORDER=PCI_BUS_ID "
  else
    echo -e "\e[33m[WARN]: Cannot find any GPU.\e[0m"
  fi
fi

DOCKER_ARGS_VOLUME="-v $(pwd):/ws "
DOCKER_WORKSPACE="-w /ws"

exec docker run -it --rm --name=${CONTAINER_NAME} \
  --net=host \
  --shm-size=4Gb \
  ${DOCKER_ARGS_GPU} \
  ${DOCKER_ARGS_GUI} \
  ${DOCKER_ARGS_VOLUME} \
  ${DOCKER_WORKSPACE} \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  /bin/bash
