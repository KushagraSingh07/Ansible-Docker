FROM gitpod/workspace-full

USER root

RUN apt-get update && apt-get install -y \
    ansible \
    openssh-client \
    docker.io \
    python3

USER gitpod
