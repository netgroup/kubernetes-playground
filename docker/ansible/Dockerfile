FROM alpine:3.16.0

LABEL maintainer="ferrari.marco@gmail.com"

RUN apk add --no-cache \
    build-base \
    git \
    libffi \
    libffi-dev \
    musl \
    openssh-client \
    openssl \
    openssl-dev \
    python3 \
    python3-dev \
    sshpass \
    && python3 -m ensurepip

WORKDIR /

RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# Install Ansible
# We use a requirements.txt file so that we can watch it for dependency updates
COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt
