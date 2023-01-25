ARG VARIANT=latest

FROM ubuntu:${VARIANT}


## Base Config
# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG upgradePackages="true"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Setup non-root user for dev-container
ARG USERNAME="vscode"
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# [Option] Select CLI version
ARG CLI_VERSION="latest"
# Enable new "BUILDKIT" mode for Docker CLI
ENV DOCKER_BUILDKIT=1
# Ignore Pip warnings about running as root
ENV PIP_ROOT_USER_ACTION=ignore

# Common python/ansible dev container config
COPY scripts/*.sh /tmp/scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive; \
    apt-get install -y apt-utils --no-install-recommends; \
    apt-get install -y gcc libssl-dev libffi-dev --no-install-recommends; \
    bash /tmp/scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}"; \
    bash /tmp/scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" "${CLI_VERSION}"; \
    # Clean up
    apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/scripts/

COPY scripts/*.sh /tmp/scripts/
COPY scripts/requirements.txt /tmp/scripts/requirements.txt
RUN bash /tmp/scripts/ansible-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}"; \
    # Clean up
    apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/scripts/

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]