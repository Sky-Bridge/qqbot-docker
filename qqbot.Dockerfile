FROM golang AS builder

RUN go env -w GO111MODULE=auto \
  && go env -w CGO_ENABLED=0 \
  && go env -w GOPROXY=https://goproxy.cn,direct

WORKDIR /build

# 使用git-host.py脚本获取githost
COPY hosts.txt /build

#  if  [[ $? != 0 ]];then


RUN cat hosts.txt >> /etc/hosts && cd /build && while timeout -k 70 60 bash -c 'git clone https://github.com/Mrs4s/go-cqhttp.git'; [ $? != 0 ];do echo "下载失败正在重试！(如多次重试不行建议手动下载仓库，修改dockerfile，copy到镜像里)" && sleep 2;done

# 如果无法访问github需要先手动把此仓库上传到机器上才行
# COPY ./go-cqhttp /build


RUN set -ex \
    && cd /build/go-cqhttp \
    && go build -ldflags "-s -w -extldflags '-static'" -o cqhttp



FROM alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache ffmpeg

COPY --from=builder /build/go-cqhttp/cqhttp /usr/bin/cqhttp

RUN chmod +x /usr/bin/cqhttp

WORKDIR /data
CMD [ "/usr/bin/cqhttp" ]