#!/usr/bin/env -S bash

clear

echo "
██╗░░██╗██╗░░░██╗██████╗░███████╗██████╗░███╗░░██╗███████╗████████╗███████╗░██████╗
██║░██╔╝██║░░░██║██╔══██╗██╔════╝██╔══██╗████╗░██║██╔════╝╚══██╔══╝██╔════╝██╔════╝
█████═╝░██║░░░██║██████╦╝█████╗░░██████╔╝██╔██╗██║█████╗░░░░░██║░░░█████╗░░╚█████╗░
██╔═██╗░██║░░░██║██╔══██╗██╔══╝░░██╔══██╗██║╚████║██╔══╝░░░░░██║░░░██╔══╝░░░╚═══██╗
██║░╚██╗╚██████╔╝██████╦╝███████╗██║░░██║██║░╚███║███████╗░░░██║░░░███████╗██████╔╝
╚═╝░░╚═╝░╚═════╝░╚═════╝░╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚══════╝░░░╚═╝░░░╚══════╝╚═════╝░

██████╗░░█████╗░░█████╗░██╗░░██╗░█████╗░░██████╗░███████╗
██╔══██╗██╔══██╗██╔══██╗██║░██╔╝██╔══██╗██╔════╝░██╔════╝
██████╔╝███████║██║░░╚═╝█████═╝░███████║██║░░██╗░█████╗░░
██╔═══╝░██╔══██║██║░░██╗██╔═██╗░██╔══██║██║░░╚██╗██╔══╝░░
██║░░░░░██║░░██║╚█████╔╝██║░╚██╗██║░░██║╚██████╔╝███████╗
╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝░╚═════╝░╚══════╝
"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

echo -e "\nchecking and installing kubectl...\n"

kubectl_location="$(command -v kubectl)"

if [ -z "$kubectl_location" ]
then
    echo "kubectl is not installed installing it right now"
    operating_system="$(uname -s)"
    architechture="$(uname -m)"
    case "${architechture}" in
        arm64*)    download_arch="arm64";;
        *)          echo "amd64"
    esac
    download_link=""
    kubectl_version="$(curl --fail-with-body -L -s https://dl.k8s.io/release/stable.txt)"
    case "${operating_system}" in
        Linux*)     download_link="https://dl.k8s.io/release/$kubectl_version/bin/linux/$download_arch/kubectl";;
        Darwin*)    download_link="https://dl.k8s.io/release/$kubectl_version/bin/darwin/$download_arch/kubectl";;
        *)          echo 'Unknown Operating system' && exit 1
    esac
    echo "You are running $operating_system with $architechture CPU"
    echo "getting version $kubectl_version of kubectl as latest and stable version"
    set -e
    curl -LO --fail-with-body "$download_link"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    set +e

else
    echo "kubectl is already installed on ${kubectl_location}"
fi