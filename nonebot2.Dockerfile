FROM  python:3.8-alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache gcc g++ make \
    && pip install virtualenv && virtualenv nonebot2 && cd nonebot2 && source ./bin/activate  && pip install nb-cli





