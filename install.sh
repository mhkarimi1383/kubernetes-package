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

Made with ❤️ by Muhammed Hussein Karimi
Email: info@karimi.dev
Blog: karimi.dev
GitHub: github.com/mhkarimi1383
Star Me At: github.com/mhkarimi1383/kubernetes-package
"
echo -e "\nNOTE: this script will ask you for your sudo password multiple times"

echo -e "\nchecking and installing kubectl...\n"

kubectl_location="$(command -v kubectl)"
git_location="$(command -v kubectl)"

if grep -q "bash" <<< "$SHELL" > /dev/null || grep -q "zsh" <<< "$SHELL" > /dev/null
then
    echo
else
    echo "run this script on bash or zsh your shell is not supported" && exit 1
fi

if [ -z "$git_location" ]
then
    echo "git is not installed install it and run me again."
else
    echo
fi

if [ -z "$kubectl_location" ]
then
    echo "kubectl is not installed installing it right now"
    operating_system="$(uname -s)"
    architechture="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    download_link=""
    kubectl_version="$(curl --fail-with-body -L -s https://dl.k8s.io/release/stable.txt)"
    case "${operating_system}" in
        Linux*)     download_link="https://dl.k8s.io/release/$kubectl_version/bin/linux/$architechture/kubectl";;
        Darwin*)    download_link="https://dl.k8s.io/release/$kubectl_version/bin/darwin/$architechture/kubectl";;
        *)          echo 'Unknown Operating system' && exit 1
    esac
    echo "You are running $operating_system with $architechture CPU"
    echo "getting version $kubectl_version of kubectl as latest and stable version"
    set -e
    curl -LO --fail-with-body "$download_link"
    chmod +x kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    sudo chown root: /usr/local/bin/kubectl
    set +e

else
    echo "kubectl is already installed on ${kubectl_location}"
fi

set_alias() {
    if grep -q "bash" <<< "$SHELL"; then
        rc_file="$HOME/.bashrc"
    fi
    if grep -q "zsh" <<< "$SHELL"; then
        rc_file="$HOME/.zshrc"
    fi
    echo "setting alias in $rc_file"
    line_to_add="command -v kubectl > /dev/null && alias k=\"kubectl\""
    if grep -Fxq "$line_to_add" "$rc_file"
    then
        echo "alias already added"
    else
        echo "$line_to_add" >> "$rc_file"
    fi
}

install_krew(){
    (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO --fail-with-body "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
    )
    if grep -q "bash" <<< "$SHELL"; then
        rc_file="$HOME/.bashrc"
    fi
    if grep -q "zsh" <<< "$SHELL"; then
        rc_file="$HOME/.zshrc"
    fi
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> "$rc_file"
}

install_kubectx(){
    PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
    kubectl krew install ctx
    kubectl krew install ns
    echo "installing fzf (fuzzy search on command line)"
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME"/.fzf
    "$HOME"/.fzf/install
    echo "kubectl ns and kubectl ctx are avaiable"
}

install_kube_ps(){
    git clone https://github.com/jonmosco/kube-ps1 "$HOME"/.kube-ps1
    if grep -q "bash" <<< "$SHELL"; then
        rc_file="$HOME/.bashrc"
    fi
    if grep -q "zsh" <<< "$SHELL"; then
        rc_file="$HOME/.zshrc"
    fi
    line_to_add='source "$HOME"/.kube-ps1/kube-ps1.sh'
    if grep -Fxq "$line_to_add" "$rc_file"
    then
        echo "kube-ps already added"
    else
        echo "$line_to_add" >> "$rc_file"
    fi
    line_to_add='PROMPT=$PROMPT'\'' $(kube_ps1) '\'''
    if grep -Fxq "$line_to_add" "$rc_file"
    then
        echo "kube-ps prompt already added"
    else
        echo "$line_to_add" >> "$rc_file"
    fi
}

read -p "Do you wish to set an alias for k=kubectl? [Yy]/[Nn] " yn
case $yn in
    [Yy]* ) set_alias;;
    [Nn]* ) echo;;
    * ) echo "Please answer [Yy] or [Nn].";;
esac

read -p "Do you wish to install kube-ps1 (Kubernetes prompt)? [Yy]/[Nn] " yn
case $yn in
    [Yy]* ) install_kube_ps;;
    [Nn]* ) echo;;
    * ) echo "Please answer [Yy] or [Nn].";;
esac

read -p "Do you wish to install kubectl krew (plugin manager for kubectl)? [Yy]/[Nn] " yn
case $yn in
    [Yy]* ) install_krew;;
    [Nn]* ) echo 'finish (other things requires this part)...' && exit;;
    * ) echo "Please answer [Yy] or [Nn].";;
esac

read -p "Do you wish to install kubens (namespace switcher) and kubectx (context switcher) using krew? [Yy]/[Nn] " yn
case $yn in
    [Yy]* ) install_kubectx;;
    [Nn]* ) echo;;
    * ) echo "Please answer [Yy] or [Nn].";;
esac

read -p "Do you wish to install neat plugin (k8s yaml clean-up)? [Yy]/[Nn] " yn
case $yn in
    [Yy]* ) kubectl krew install neat && echo "kubect neat is available now";;
    [Nn]* ) echo;;
    * ) echo "Please answer [Yy] or [Nn].";;
esac
