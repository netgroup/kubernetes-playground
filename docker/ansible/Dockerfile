FROM alpine:3.15.4

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

# We use a requirements.txt file so that we can watch it for dependency updates.
# It's in a separate directory because we can't customize the requirements file
# name that dependabot watches.
COPY pre-requisites/requirements.txt pre-requirements.txt
RUN pip3 install --no-cache-dir --upgrade -r pre-requirements.txt

# Install Ansible
# We use a requirements.txt file so that we can watch it for dependency updates
COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt
