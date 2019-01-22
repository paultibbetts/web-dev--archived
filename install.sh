#!/bin/sh

# Variables
user="${USER}"
repo="https://github.com/ptibbetts/web-dev.git"
install="$HOME/.web-dev"

# Text formatting
bold=$(tput bold)
normal=$(tput sgr0)

echo() {
  printf "$1\n"
}

confirm() {
  read -r -p "${1}" response
  case "$response" in
    [yY][eE][sS]|[yY])
      true
      ;;
    *)
      false
      ;;
    esac
}

# Confirmation
if ! confirm "Are you sure you want to do this? [y\N]: "; then
  echo "Cancelling…"
  exit
fi

# Exit if the scripts run into any errors
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT
set -e

# Clone the repository to the local drive and cd into it
if [ -d $install ]; then
  echo "${bold}Playbook:${normal} Already installed, attempting to update…"
  cd $install
  git pull origin master
else
  echo "${bold}Playbook:${normal} Cloning…"
  git clone $repo $install
  cd $install
fi

echo "${bold}Ansible:${normal} Installing roles…"
ansible-galaxy install -r requirements.yml 

echo "${bold}Installing Web Development tools for user ${user}…"
ansible-playbook playbook.yml -e install_user=${user} -i hosts --ask-become-pass

echo "${bold}Done!"