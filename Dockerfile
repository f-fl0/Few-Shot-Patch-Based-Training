# ========================================
FROM ubuntu:20.04 as base

ARG APT_MIRROR="http://ftp.yz.yamagata-u.ac.jp/pub/linux/ubuntu/archives/ubuntu"
RUN if [ "${APT_MIRROR}" != "" ]; then \
      sed --in-place --regexp-extended "s|http://archive.ubuntu.com/ubuntu|${APT_MIRROR}|" /etc/apt/sources.list; \
    fi

ENV DEBIAN_FRONTEND noninteractive

# ========================================
FROM base as builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    cmake \
    g++ \
    make \
    libopencv-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR ws

RUN mkdir compiled_tools

COPY _tools .

RUN for tool in bilateralAdv disflow gauss; do \
    mkdir -p ${tool}/build; \
    cd ${tool}/build; \
    cmake ..; \
    make; \
    cp ${tool} /ws/compiled_tools/; \
    cd ../..; \
  done;

# ========================================
FROM base

ENV PYTHONUNBUFFERED=1

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libopencv-video-dev \
    python-is-python3 \
    python3-pip \
  && rm -rf /var/lib/apt/lists/* \
  && python -m pip install --no-cache-dir --upgrade pip

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt \
  && rm -f requirements.txt

COPY --from=builder /ws/compiled_tools/* /usr/bin/
