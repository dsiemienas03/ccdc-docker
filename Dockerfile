ARG BASE_IMG="ubuntu:oracular-20241120"
ARG PYCMD="/usr/bin/python3"
ARG PKGMGR_PRESERVE_CACHE=""
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS="-v"
ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS=""
ARG PKGMGR="/usr/bin/apt-get"
# Add user
FROM $BASE_IMG AS base
ARG BASE_IMG
ARG PYCMD
ARG PKGMGR_PRESERVE_CACHE
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS
ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS
ARG PKGMGR
RUN set -ex ;\
    apt-get update ;\
    apt-get install -y --no-install-recommends \
    apt-utils ;\
    \
    apt-get install -y --no-install-recommends \ 
    ansible \
    python3 \
    python3-pip ;\
    # git \
    # vim \
    # tmux ;\
    rm -rf /var/apt/cache /var/lib/apt/lists/*

COPY _build/scripts/ /output/scripts/
RUN useradd ansible -ms /bin/bash
COPY --chown=ansible:ansible config/ ./config

SHELL ["/bin/bash", "-c"]




# RUN ansible-galaxy collection install -r config/requirements.yml

FROM base AS galaxy
ARG BASE_IMG
ARG PYCMD
ARG PKGMGR_PRESERVE_CACHE
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS
ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS
ARG PKGMGR
# ADD --chown=ansible:ansible submodules/ccdc-ansible ./dsu
# WORKDIR /build
# RUN mkdir -p /usr/share/ansible
# RUN set -ex ;\
#     ansible-galaxy collection install dsu/ ;\
#     rm -rf dsu-ccdc-1.0.0.tar.gz .github .config
RUN /output/scripts/check_galaxy
COPY _build /build
COPY submodules/ccdc-ansible /build/dsu
WORKDIR /build
RUN mkdir -p /usr/share/ansible
RUN ansible-galaxy role install $ANSIBLE_GALAXY_CLI_ROLE_OPTS -r requirements.yml -vvv --roles-path "/usr/share/ansible/roles"
RUN ANSIBLE_GALAXY_DISABLE_GPG_VERIFY=1 ansible-galaxy collection install $ANSIBLE_GALAXY_CLI_COLLECTION_OPTS -r requirements.yml --collections-path "/usr/share/ansible/collections"
RUN ansible-galaxy collection install /build/dsu --collections-path "/usr/share/ansible/collections"


FROM base AS pip
ENV PIP_BREAK_SYSTEM_PACKAGES=1
ARG BASE_IMG
ARG PYCMD
ARG PKGMGR_PRESERVE_CACHE
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS
ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS
ARG PKGMGR
WORKDIR /build

RUN $PYCMD -m pip install --no-cache-dir bindep pyyaml packaging

RUN set -ex ;\
    pip install --break-system-packages --no-cache-dir \
    -r config/requirements.txt

FROM base AS final
RUN /output/scripts/check_ansible $PYCMD
WORKDIR /home/ansible
COPY --from=galaxy /usr/share/ansible /usr/share/ansible
COPY --chown=ansible:ansible src/ ./


USER ansible
ENTRYPOINT ["top", "-b"]
