FROM alpine:3.14.0

LABEL maintainer="ferrari.marco@gmail.com"

RUN apk add --no-cache \
    build-base=0.5-r2 \
    git=2.26.2-r0 \
    libffi=3.3-r2 \
    libffi-dev=3.3-r2 \
    musl=1.1.24-r10 \
    openssh-client=8.3_p1-r1 \
    openssl=1.1.1i-r0 \
    openssl-dev=1.1.1i-r0 \
    python3=3.8.5-r0 \
    python3-dev=3.8.5-r0 \
    sshpass=1.06-r0

RUN python3 -m ensurepip

# We use a requirements.txt file so that we can watch it for dependency updates.
# It's in a separate directory because we can't customize the requirements file
# name that dependabot watches.
COPY pre-requisites/requirements.txt pre-requirements.txt
RUN pip3 install --no-cache-dir --upgrade -r pre-requirements.txt

# Install Ansible
# We use a requirements.txt file so that we can watch it for dependency updates
COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt
