#!/bin/bash

# 1. Generate SSH keys
mkdir -p .ssh
ssh-keygen -t rsa -b 4096 -f .ssh/ansible_key -N ""
chmod 700 .ssh && chmod 600 .ssh/ansible_key && chmod 644 .ssh/ansible_key.pub

# 2. Create Docker containers
for i in {1..5}; do
    docker run -d --name server$i -p 222$i:22 ubuntu sleep infinity
done

# 3. Setup each container
for i in {1..5}; do
    docker exec server$i bash -c "apt-get update && apt-get install -y openssh-server python3"
    docker exec server$i bash -c "mkdir -p /root/.ssh"
    docker exec server$i bash -c "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config"
    docker exec server$i bash -c "echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config"
    docker exec server$i bash -c "echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config"
    docker cp .ssh/ansible_key.pub server$i:/root/.ssh/authorized_keys
    docker cp .ssh/ansible_key server$i:/root/.ssh/id_rsa
    docker exec server$i bash -c "chown -R root:root /root/.ssh"
    docker exec server$i bash -c "chmod 700 /root/.ssh && chmod 600 /root/.ssh/id_rsa && chmod 644 /root/.ssh/authorized_keys"
    docker exec server$i bash -c "service ssh start"
done
