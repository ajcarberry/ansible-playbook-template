#!/usr/bin/env bash
#
# Syntax: ./ansible-debian.sh [enable non-root pip] [non-root user]

ENABLE_NONROOT_PIP=${1:-"true"}
USERNAME=${2:-"automatic"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in ${POSSIBLE_USERS[@]}; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

# Function to run apt-get if needed
apt_get_update_if_needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Install Python3 and Pip
apt-get install -y python3 python3-pip --no-install-recommends

# Install pip, virtualenv updates and Ansible + dependencies
if [ "${USERNAME}" = "root" ] && [ "${ENABLE_NONROOT_PIP}" = false ]; then 
    python3 -m pip install --no-cache-dir --upgrade pip virtualenv --user
    python3 -m pip install --no-cache-dir -r /tmp/scripts/requirements.txt --user
else
    su - $USERNAME -c "python3 -m pip install --no-cache-dir --upgrade pip virtualenv"
    su - $USERNAME -c "python3 -m pip install --no-cache-dir -r /tmp/scripts/requirements.txt"
fi

apt-get install -y sshpass --no-install-recommends