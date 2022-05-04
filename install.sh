#!/usr/bin/env -S bash

clear

echo -e "
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

Made with ❤️  by Muhammed Hussein Karimi
📧 Email: info@karimi.dev
🌐 Blog: karimi.dev
GitHub: github.com/mhkarimi1383
Give me ⭐ on github: github.com/mhkarimi1383/kubernetes-package
"
echo -e "\e[32m\e[1m⚪ NOTE:\e[0m this script will ask you for your sudo password multiple times"

echo -e "\e[32m\e[1m🟢 INFO:\e[0mchecking and installing kubectl...\n"

kubectl_location="$(command -v kubectl)"
git_location="$(command -v git)"

if grep -q "bash" <<< "$SHELL" > /dev/null || grep -q "zsh" <<< "$SHELL" > /dev/null
then
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m $SHELL detected on running terminal"
else
    echo -e "\033[31m\e[1m🔴 ERROR:\e[0m run this script on bash or zsh your shell is not supported" && exit 1
fi

if [ -z "$git_location" ]
then
    echo -e "\033[31m\e[1m🔴 ERROR:\e[0m git is not installed install it and run me again."
else
    echo
fi

install_kubectl() {
    operating_system="$(uname -s)"
    architechture="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    download_link=""
    kubectl_version="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
    case "${operating_system}" in
        Linux*)     download_link="https://dl.k8s.io/release/$kubectl_version/bin/linux/$architechture/kubectl";;
        Darwin*)    download_link="https://dl.k8s.io/release/$kubectl_version/bin/darwin/$architechture/kubectl";;
        *)          echo 'Unknown Operating system' && exit 1
    esac
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m You are running $operating_system with $architechture CPU"
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m getting version $kubectl_version of kubectl as latest and stable version"
    set -e
    curl -LO "$download_link"
    chmod +x kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    sudo chown root: /usr/local/bin/kubectl
    set +e
}

if [ -z "$kubectl_location" ]
then
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m kubectl is not installed installing it right now"
    install_kubectl
else
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m kubectl $(kubectl version --client --short=true) is already installed on ${kubectl_location}"
    while true
    do
        read -p "Do you want to reinstall or upgrade it? [Yy]/[Nn] " yn
        case $yn in
            [Yy]* ) rm -f "$kubectl_location" && install_kubectl && break;;
            [Nn]* ) break;;
            * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
        esac
    done
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
        echo -e "\e[32m\e[1m🟢 INFO:\e[0m alias already added"
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
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
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
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m installing fzf (fuzzy search on command line)"
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME"/.fzf
    "$HOME"/.fzf/install
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m kubectl ns and kubectl ctx are avaiable"
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
        echo -e "\e[32m\e[1m🟢 INFO:\e[0m kube-ps already added"
    else
        echo "$line_to_add" >> "$rc_file"
    fi
    line_to_add='PROMPT=$PROMPT'\'' $(kube_ps1) '\'''
    if grep -Fxq "$line_to_add" "$rc_file"
    then
        echo -e "\e[32m\e[1m🟢 INFO:\e[0m kube-ps prompt already added"
    else
        echo "$line_to_add" >> "$rc_file"
    fi
}

while true
do
    read -p "Do you wish to set an alias for k=kubectl? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) set_alias && break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install kube-ps1 (Kubernetes prompt)? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) install_kube_ps && break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install kubectl krew (plugin manager for kubectl)? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) install_krew && break;;
        [Nn]* ) echo -e '\e[32m\e[1m🟢 INFO:\e[0m finish (other things requires this part)...' && exit;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install kubens (namespace switcher) and kubectx (context switcher) using krew? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) install_kubectx && break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install neat plugin (k8s yaml clean-up)? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) kubectl krew install neat && echo "kubect neat is available now" && break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

echo -e "\e[5m🚀\e[0m Everything is installed and ready for you Just Enjoy"