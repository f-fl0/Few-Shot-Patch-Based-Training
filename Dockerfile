# FROM nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu20.04
FROM ubuntu:20.04

ARG APT_MIRROR="http://ftp.yz.yamagata-u.ac.jp/pub/linux/ubuntu/archives/ubuntu"
RUN if [ "${APT_MIRROR}" != "" ]; then \
      sed --in-place --regexp-extended "s|http://archive.ubuntu.com/ubuntu|${APT_MIRROR}|" /etc/apt/sources.list; \
    fi

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    python-is-python3 \
    python3-pip \
  && rm -rf /var/lib/apt/lists/* \
  && python -m pip install --no-cache-dir --upgrade pip

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt \
  && rm -f requirements.txt
