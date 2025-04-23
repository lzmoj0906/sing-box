#!/bin/bash

# Docker 安装脚本
# 适用于大多数Linux发行版

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用root用户或通过sudo运行此脚本"
    exit 1
fi

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 函数：检查命令是否存在
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

# 函数：获取系统信息
get_os_info() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/redhat-release ]; then
        OS=$(cat /etc/redhat-release | cut -d ' ' -f 1)
        VER=$(cat /etc/redhat-release | cut -d ' ' -f 3)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
}

# 显示系统信息
get_os_info
echo -e "${GREEN}系统信息: ${OS} ${VER}${NC}"

# 安装依赖
echo -e "${YELLOW}安装必要依赖...${NC}"
if [[ "$OS" =~ "Ubuntu" ]] || [[ "$OS" =~ "Debian" ]]; then
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
elif [[ "$OS" =~ "CentOS" ]] || [[ "$OS" =~ "Red Hat" ]] || [[ "$OS" =~ "Fedora" ]]; then
    yum install -y yum-utils device-mapper-persistent-data lvm2
else
    echo -e "${RED}不支持的Linux发行版${NC}"
    exit 1
fi

# 添加Docker官方GPG密钥
echo -e "${YELLOW}添加Docker GPG密钥...${NC}"
curl -fsSL https://download.docker.com/linux/${OS,,}/gpg | sudo apt-key add -

# 添加Docker仓库
echo -e "${YELLOW}添加Docker仓库...${NC}"
if [[ "$OS" =~ "Ubuntu" ]] || [[ "$OS" =~ "Debian" ]]; then
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${OS,,} $(lsb_release -cs) stable"
    apt-get update
elif [[ "$OS" =~ "CentOS" ]] || [[ "$OS" =~ "Red Hat" ]]; then
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
elif [[ "$OS" =~ "Fedora" ]]; then
    yum-config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
fi

# 安装Docker
echo -e "${YELLOW}安装Docker引擎...${NC}"
if [[ "$OS" =~ "Ubuntu" ]] || [[ "$OS" =~ "Debian" ]]; then
    apt-get install -y docker-ce docker-ce-cli containerd.io
elif [[ "$OS" =~ "CentOS" ]] || [[ "$OS" =~ "Red Hat" ]] || [[ "$OS" =~ "Fedora" ]]; then