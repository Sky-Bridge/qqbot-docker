#!/usr/bin/env bash

set -euo pipefail

# go-cqhttp相关变量
IMAGE_NAME="${IMAGE_NAME:-qqbot}"
VERSION="${VERSION:-latest}"
GO_CQHTTP_NAME=${GO_CQHTTP_NAME:-go_cqhttp}
GO_CQHTTP_VOLUME=${GO_CQHTTP_VOLUME:-/data/qqbot/go_cqhttp}
GO_CQHTTP_PORT=${GO_CQHTTP_PORT:-6700-6710}
# config.yml文件变量
UIN = ""
HTTP_PORT= "6700"
WS_PORT = "6701"







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

function initialize_go_cqhttp(){
    docker run --rm -it --name ${GO_CQHTTP_NAME} -v ${GO_CQHTTP_VOLUME}:/data -p ${GO_CQHTTP_PORT}:${GO_CQHTTP_PORT}  ${IMAGE_NAME}:${VERSION}
}

function run_go_cqhttp_image(){
    docker run -dit --name ${GO_CQHTTP_NAME} -v ${GO_CQHTTP_VOLUME}:/data -p ${GO_CQHTTP_PORT}:${GO_CQHTTP_PORT} --restart always ${IMAGE_NAME}:${VERSION}
}

function install(){
    echo "开始安装!"
    echo "开始编译go-cqhttp镜像"
    sleep 3
    status build_image
    echo "go-cqhttp镜像编译完成！"
    echo "开始初始化go-cqhttp镜像"
    sleep 2
    initialize_go_cqhttp
    echo "初始化完成！"
    echo "开始按照默认变量修改config.yml文件！"
    sed -ie "s#123456#$UIN#g" "s#5700#$HTTP_PORT#g" "s#6700#$WS_PORT#g"  ${GO_CQHTTP_VOLUME}/config.yml
    echo "修改完成！"
    echo "开始重新启动go-cqhttp！"
    run_go_cqhttp_image
    echo "启动完成，开始登陆go-cqhttp"
    echo "完成登陆后可按ctrl+c退出"
    sleep 5
    docker logs -f ${GO_CQHTTP_NAME}

}


case "$1" in
    --git-hosts)
        git_hosts
        ;;
    *)
        build "$@"
        ;;
esac




