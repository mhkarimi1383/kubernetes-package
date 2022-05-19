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
            [Yy]* ) rm -f "$kubectl_location" && install_kubectl; break;;
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

install_dmg(){
    set -x
    tempd=$(mktemp -d)
    curl $1 > $tempd/pkg.dmg
    listing=$(sudo hdiutil attach $tempd/pkg.dmg | grep Volumes)
    volume=$(echo "$listing" | cut -f 3)
    found=false
    for file in "$volume"/*.app
    do
        if [ -e "$file" ]
        then
            sudo cp -rf "$volume"/*.app /Applications
            found=true
            break
        fi
    done
    if [ "$found" = false ]
    then
        for file in "$volume"/*.pkg
        do
            if [ -e "$file" ]
            then
                package=$(ls -1 "$volume" | grep .pkg | head -1)
                sudo installer -pkg "$volume"/"$package" -target /
                found=true
                break
            fi
        done
    fi
    sudo hdiutil detach "$(echo "$listing" | cut -f 1)"
    rm -rf $tempd
    set +x
}

install_deb(){
    TEMP_DEB="$(mktemp)"
    wget -O "$TEMP_DEB" "$1"
    sudo dpkg -i "$TEMP_DEB"
    rm -f "$TEMP_DEB"
}

install_rpm(){
    TEMP_RPM="$(mktemp)"
    wget -O "$TEMP_RPM" "$1"
    sudo rpm -ivh "$TEMP_RPM"
    rm -f "$TEMP_RPM"
}

install_appimage(){
    TEMP_APPIMAGE="$(mktemp -d)"
    wget -O "$TEMP_APPIMAGE/Lens.Appimage" "$1"
    chmod +x "$TEMP_APPIMAGE"
    set -x
    "$TEMP_APPIMAGE/Lens.Appimage" --appimage-extract
    sudo mkdir -p /usr/share/lens
    sudo mv "$TEMP_APPIMAGE"/squashfs-root/* /usr/share/lens
    sudo install -Dm 644 /usr/share/lens/usr/share/icons/hicolor/512x512/apps/lens.png /usr/share/icons/hicolor/512x512/apps/open-lens.png
    sudo install -Dm 644 "$(pwd)"/lens.desktop /usr/share/applications/lens.desktop
    sudo ln -sf /usr/share/lens/lens /usr/bin/open-lens
    sudo chmod -x /usr/share/lens/*.so
    sudo rm -rf /usr/share/lens/AppRun
    sudo rm -rf /usr/share/lens/lens.{desktop,png}
    sudo rm -rf /usr/share/lens/usr
    sudo rm -rf /usr/share/lens/resources/extensions/*/dist/*-arm64
    rm -rf "$TEMP_APPIMAGE"
    set +x
}

install_lens(){
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m detecting the latest version of lens"
    lens_version=$(curl https://api.k8slens.dev/binaries/latest.json | tr ',' "\n" | tr -d '{' | tr -d '}' | head -1 | sed 's/"version"://g' | tr -d '"')
    deb_link="https://api.k8slens.dev/binaries/Lens-$lens_version.amd64.deb"
    rpm_link="https://api.k8slens.dev/binaries/Lens-$lens_version.x86_64.rpm"
    appimage_link="https://api.k8slens.dev/binaries/Lens-$lens_version.x86_64.AppImage"
    macos_arm_link="https://api.k8slens.dev/binaries/Lens-$lens_version-arm64.dmg"
    macos_intel_link="https://api.k8slens.dev/binaries/Lens-$lens_version.dmg"
    
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m installing it depending on you Operating System and Architechture"
    continue_installion=true
    operating_system="$(uname -s)"
    if [ "$operating_system" = "Darwin" ]
    then
        architechture="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
        if [ "$architechture" = "arm64" ]
        then
            echo -e "\e[32m\e[1m🟢 INFO:\e[0m installing for Mac OS M1 Silicon"
            install_dmg "$macos_arm_link"
        else
            echo -e "\e[32m\e[1m🟢 INFO:\e[0m installing for Mac OS intel"
            install_dmg "$macos_intel_link"
        fi
            
    else
        command -v dpkg > /dev/null && echo -e "\e[32m\e[1m🟢 INFO:\e[0m installing for Debian based systems" && install_deb "$deb_link" && continue_installion=false
        "$continue_installion" && command -v rpm > /dev/null && echo -e "\e[32m\e[1m🟢 INFO:\e[0m installing for RedHat based systems" && install_rpm "$rpm_link" && continue_installion=false
        "$continue_installion" && echo -e "\e[32m\e[1m🟢 INFO:\e[0m installing for other Linux systems using appimage file" && install_appimage "$appimage_link" && continue_installion=false
    fi
}

install_helm(){
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m installing helm"
    script_location=$(mktemp)
    curl -fsSL -o "$script_location" https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 "$script_location"
    "$script_location"
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m done with helm"
}

install_shell_completion(){
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m detecting what type of completion I should install"
    operating_system="$(uname -s)"
    if grep -q "bash" <<< "$SHELL"; then
        rc_file="$HOME/.bashrc"
        if type _init_completion > dev/null; then
            echo 'source <(kubectl completion bash)' >> "$rc_file"
            if grep -q "k=kubectl" "$rc_file"; then
                echo 'complete -F __start_kubectl k' >> "$rc_file"
            fi
        fi
    fi
    if grep -q "zsh" <<< "$SHELL"; then
        rc_file="$HOME/.zshrc"
        if type _init_completion > dev/null; then
            echo 'source <(kubectl completion zsh)' >> "$rc_file"
            sed -i '1s/^/autoload -Uz compinit /' "$rc_file"
            sed -i '1s/^/compinit /' "$rc_file"
        fi
    fi
    echo -e "\e[32m\e[1m🟢 INFO:\e[0m done with shell completion"
}

while true
do
    read -p "Do you wish to set an alias for k=kubectl? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) set_alias; break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install kube-ps1 (Kubernetes prompt)? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) install_kube_ps; break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to enable kubectl shell auto-completion? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) install_shell_completion; break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install lens (k8s IDE)? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) install_lens && echo "\e[32m\e[1m🟢 INFO:\e[0m lens installed"; break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install helm (k8s Package manager)? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) install_helm; break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install kubectl krew (plugin manager for kubectl)? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) install_krew; break;;
        [Nn]* ) echo -e '\e[32m\e[1m🟢 INFO:\e[0m finish (other things requires this part)...' && exit;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install stern plugin (Multi pod and container log tailing for Kubernetes)? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) kubectl krew install stern && echo "\e[32m\e[1m🟢 INFO:\e[0m kubect stern is available now"; break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install kubens (namespace switcher) and kubectx (context switcher) using krew? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) install_kubectx; break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

while true
do
    read -p "Do you wish to install neat plugin (k8s yaml clean-up)? [Yy]/[Nn] " yn
    case $yn in
        [Yy]* ) kubectl krew install neat && echo "kubect neat is available now"; break;;
        [Nn]* ) break;;
        * ) echo -e "\e[33m\e[1m🟠 BAD INPUT:\e[0m Please answer [Yy] or [Nn].";;
    esac
done

echo -e "\e[5m🚀\e[0m Everything is installed and ready for you Just Enjoy"
