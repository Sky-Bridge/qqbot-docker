#!/usr/bin/env bash

set -euo pipefail

# go-cqhttp相关变量
GO_CQHTTP_IMAGE_NAME="${GO_CQHTTP_IMAGE_NAME:-qqbot}"
VERSION="${VERSION:-latest}"
GO_CQHTTP_NAME=${GO_CQHTTP_NAME:-go_cqhttp}
GO_CQHTTP_VOLUME=${GO_CQHTTP_VOLUME:-/data/qqbot/go_cqhttp}
GO_CQHTTP_DOCKERFIRE=${GO_CQHTTP_DOCKERFIRE:-go_cqhttp.Dockerfile}
GO_CQHTTP_PORT=${GO_CQHTTP_PORT:-6700-6710}
# config.yml文件变量
UIN=""
HTTP_PORT="6700"
WS_PORT="6701"

# ATRI相关变量
ATRI_IMAGE_NAME="${ATRI_IMAGE_NAME:-atri}"
VERSION="${VERSION:-latest}"
ATRI_NAME="${ATRI_NAME:-atri}"
ATRI_VOLUME=${ATRI_VOLUME:-/data/qqbot/ATRI}
MAIN_HOME="${MAIN_HOME:-/data/qqbot}"
ATRI_DOCKERFILE=${ATRI_DOCKERFILE:-nonebot2.Dockerfile}
ATRI_HOST=${ATRI_HOST:-0.0.0.0}
ATRI_PORT=${ATRI_PORT:-20000}
ATRI_ADMIN_QQ=${ATRI_ADMIN_QQ:-1234567890}



# 如果为国内机器，多次运行脚本无法下载仓库，可以试试加上hosts，再试试，还是不行的话，只能手动上传了

function status() {
    echo -e "\033[35m >>>   $*\033[0;39m"
}

function git_hosts(){
    python git-host.py
}

function build_image(){
    if [ "$1" = "build" ]; then
        case "$2" in
        --go_cqhttp)
            docker build -f ${GO_CQHTTP_DOCKERFIRE} -t ${GO_CQHTTP_IMAGE_NAME}:${VERSION}  .
            ;;
        --atri)
            docker build -f ${ATRI_DOCKERFILE}  -t  ${ATRI_NAME}:${VERSION} .
            ;;
        --help)
            status "目前支持2种docker自动化安装，1是--go_cqhttp,2是--atri"
            ;;
        *)
            status "暂不支持其他组件！"
            ;;
        esac
    fi
}

function initialize_go_cqhttp(){
    docker run --rm -it --name ${GO_CQHTTP_NAME} -v ${GO_CQHTTP_VOLUME}:/data -p ${GO_CQHTTP_PORT}:${GO_CQHTTP_PORT}  ${GO_CQHTTP_IMAGE_NAME}:${VERSION}
}
function initialize_atri(){
    cd ${MAIN_HOME} && while timeout -k 70 60 bash -c 'git clone https://github.com/Kyomotoi/ATRI.git'; [ $? != 0 ];do echo "下载失败正在重试！(如多次重试不行建议手动下载仓库，修改dockerfile，copy到镜像里)" && sleep 2;done
    sed -i 's/pathlib>=1.0.1/#pathlib>=1.0.1/g' ${ATRI_VOLUME}/requirements.txt
    sed -i -e "s#127.0.0.1#${ATRI_HOST}#g" -e "s#20000#${ATRI_PORT}#/g" -e 's/enabled:\ true/enabled:\ false/g' -e "s/\"1234567890\"/\"${ATRI_ADMIN_QQ}\"/g" ${ATRI_VOLUME}/config.yml
}

function run_go_cqhttp_image(){
    docker run -dit --name ${GO_CQHTTP_NAME} -v ${GO_CQHTTP_VOLUME}:/data -p ${GO_CQHTTP_PORT}:${GO_CQHTTP_PORT} --restart always ${GO_CQHTTP_IMAGE_NAME}:${VERSION}
}
function run_atri(){
    docker run -dit --name ${ATRI_NAME} -v ${ATRI_VOLUME}:/data/ATRI -p ${ATRI_PORT}:${ATRI_PORT}  --restart always ${ATRI_IMAGE_NAME}:${VERSION}
}


function install(){
    status "开始安装!"
    status "开始编译go-cqhttp镜像"
    sleep 3
    build_image build --go_cqhttp
    status "go-cqhttp镜像编译完成！"
    status "开始初始化go-cqhttp镜像"
    sleep 2
    initialize_go_cqhttp
    status "初始化完成！"
    status "开始按照默认变量修改config.yml文件！"
    sed -i -e "s#6700#$WS_PORT#"  ${GO_CQHTTP_VOLUME}/config.yml
    sed -i -e "s#1233456#$UIN#g" -e "s#5700#$HTTP_PORT#"   ${GO_CQHTTP_VOLUME}/config.yml
    status "修改完成！"
    status "开始重新启动go-cqhttp！"
    run_go_cqhttp_image
    status "启动完成，开始登陆go-cqhttp"
    status "完成登陆后可按ctrl+c退出"
    sleep 5
    docker logs -f ${GO_CQHTTP_NAME}
#    status "go-cqhttp，已经配置完成，现在开始配置ATRI！"
#    initialize_atri
#    build_image build --atri
#    status "ATRI配置完成，现在开始启动ATRI！"
#    run_atri
#    status "现在开始查看ATRI运行情况，运行正常请按ctrl+c退出日志查看！"
#    sleep 5
#    docker logs -f ${ATRI_NAME}
}




case "$1" in
    --git-hosts)
        git_hosts
        ;;
    -h|--help)
        status "脚本带了一个网上找的自动获取github的hosts列表，使用--git-host来进行更新，如果国内主机无法下载,可以试试，还是不行的话只能手动去下载了！"
        status "目前支持2种docker镜像编译："
        status "1：脚本后面加参数build --go_cqhttp"
        status "2：脚本后面加参数build --atri"
        status "安装的话只要使用install就可以了！"
        ;;
    install)
        install
        ;;
    build)
        build_image $1 $2
        ;;
    *)
        status "请使用-h或--help获取帮助信息！"
        ;;
esac




