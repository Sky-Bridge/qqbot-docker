#!/usr/bin/env bash

set -euo pipefail

# go-cqhttp相关变量
IMAGE_NAME="${IMAGE_NAME:-qqbot}"
VERSION="${VERSION:-latest}"
GO_CQHTTP_NAME=${GO_CQHTTP_NAME:-go_cqhttp}
GO_CQHTTP_VOLUME=${GO_CQHTTP_VOLUME:-/data/qqbot/go_cqhttp}
GO_CQHTTP_PORT=${GO_CQHTTP_PORT:-6700-6710}

# 如果为国内机器，多次运行脚本无法下载仓库，可以试试加上hosts，再试试，还是不行的话，只能手动上传了

function status() {
    echo -e "\033[35m >>>   $*\033[0;39m"
}

function git_hosts(){
    python git-host.py
}

function build_image(){
    docker build -f qqbot.Dockerfile -t ${IMAGE_NAME}:${VERSION}  .
}

function run(){
    docker run -dit ${GO_CQHTTP_NAME} -v ${GO_CQHTTP_VOLUME}:/data -p ${GO_CQHTTP_PORT}:${GO_CQHTTP_PORT} --restart always ${IMAGE_NAME}:${VERSION}
}






