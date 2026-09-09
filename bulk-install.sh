#!/bin/bash
set  -eu -o pipefail

# 最初で sudo を実行してパスワードを入力させる
echo '管理者権限を使用します'
sudo echo 'OK'

TIMESTAMP=`date +%Y-%m-%d`

# apt のリポジトリサーバーを変更
sudo sed -i."$TIMESTAMP".bak 's/[a-z]*\.\{0,1\}archive.ubuntu.com/ftp.udx.icscoe.jp\/Linux/g' /etc/apt/sources.list.d/ubuntu.sources
# deb-src の有効化
sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
# 現状の更新
sudo apt update
sudo apt upgrade -y

# Ubuntu 追加パッケージ
sudo apt install -y \
    ubuntu-restricted-extras

# クリーン
sudo apt autoremove --purge -y

# 日本語関連
sudo apt install -y \
    vim \
    language-pack-ja \
    language-pack-gnome-ja \
    gnome-user-docs-ja \
    fcitx5 \
    fcitx5-config-qt \
    fcitx5-mozc \
    mozc-utils-gui \
    fcitx5-frontend-all \
    fonts-noto-cjk-extra \
    gnome-shell-extension-manager

mkdir -p ~/.config/autostart
sudo tee ~/.config/autostart/fcitx5.desktop <<EOF
[DESKTOP Entry]
Type=Application
Exec=/usr/bin/fcitx5 -r -d
NAME[ja_JP]=fcitx5
NAME=fcitx5
Terminal=false
StartupNotify=false
EOF

# Docker 関連
sudo apt remove -y $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
sudo apt install -y \
    ca-certificates \
    curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    docker-ce-rootless-extras \
    uidmap \
    slirp4netns \
    cgroup-lite

sudo apt install -y \
    dbus-user-session \
    systemd-container

sudo systemctl disable --now docker.service docker.socket
sudo rm /var/run/docker.sock
dockerd-rootless-setuptool.sh install
sudo loginctl enable-linger $USER

sudo mkdir -p /etc/systemd/system/user@.service.d
sudo tee /etc/systemd/system/user@.service.d/delegate.conf <<EOF
[Service]
Delegate=cpuset io
EOF

sudo systemctl daemon-reload
systemctl --user restart docker

# Google Chrome インストール
curl --output-dir=/tmp -fsSL -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb  
sudo apt install -y /tmp/google-chrome-stable_current_amd64.deb
sudo apt update
sudo apt modernize-sources -y

# libvirt(qemu-kvm)
sudo apt install -y \
    qemu-system-x86 \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virt-manager \
    ovmf

# クリーン
sudo apt autoremove --purge -y

# Vagrant インストール
curl --output-dir=/tmp -fsSL -O https://releases.hashicorp.com/vagrant/2.4.9/vagrant_2.4.9_linux_amd64.zip
unzip /tmp/vagrant_2.4.9_linux_amd64.zip -d /tmp
sudo install -m 0755 -o root -g root -t /usr/local/bin /tmp/vagrant

# vagrant-libvirt プラグインのインストール
sudo apt install -y \
    nfs-kernel-server \
    ebtables \
    dnsmasq-base \
    libguestfs-tools \
    libxslt1-dev \
    libxml2-dev \
    libvirt-dev \
    zlib1g-dev \
    ruby-dev \
    ruby-fog-libvirt \
    unzip

sudo systemctl enable --now nfs-server
sudo apt build-dep -y ruby-libvirt
vagrant plugin install vagrant-libvirt
mkdir -p $HOME/.vagrant.d
tee $HOME/.vagrant.d/Vagrantfile <<EOF
Vagrant.configure('2') do |config|
  config.ssh.forward_agent = true
  config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: "4", nfs_udp: false
end
EOF

sudo usermod -aG libvirt,kvm $USER

echo "再起動します..."
sleep 3
sudo reboot
