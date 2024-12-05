FROM ubuntu:oracular-20241009


RUN set -ex ;\
    apt-get update ;\
    apt-get install -y --no-install-recommends \
    apt-utils ;\
    apt-get install -y --no-install-recommends \ 
    ansible \
    curl \
    git \
    python3 \
    python3-setuptools \
    python3-pip \
    software-properties-common \
    vim \
    tmux ;\
    rm -rf /var/lib/apt/lists/*

# wget -O- https://apt.releases.hashicorp.com/gpg | \
# gpg --dearmor | \
# sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null ;\
# gpg --no-default-keyring \
# --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
# --fingerprint ;\
RUN \
    lsb-release -cs ;\
    echo "deb \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list ;\
    sudo apt-get update ;\
    sudo apt-get install -y \
    terraform ;\
    rm -rf /var/lib/apt/lists/*




# Add user
RUN useradd ansible -ms /bin/bash

WORKDIR /home/ansible
USER ansible

COPY --chown=ansible:ansible config/ ./config

SHELL ["/bin/bash", "-c"]

RUN set -ex ;\
    pip install --break-system-packages --no-cache-dir \
    -r config/requirements.txt

RUN ansible-galaxy collection install -r config/requirements.yml

ADD --chown=ansible:ansible https://github.com/dsiemienas03/ccdc-ansible.git .

RUN set -ex ;\
    ansible-galaxy collection build dsu/ccdc/ ;\
    ansible-galaxy collection install --offline dsu-ccdc-1.0.0.tar.gz ;\
    rm -rf dsu-ccdc-1.0.0.tar.gz .github .config

COPY --chown=ansible:ansible src/ ./
ENTRYPOINT ["top", "-b"]
