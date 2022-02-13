FROM  python:3.8

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
#    && apk add --no-cache gcc g++ make \
#    && pip install virtualenv && virtualenv nonebot2 && cd nonebot2 && source ./bin/activate  && pip install nb-cli

# pip install tensorflow -i https://pypi.tuna.tsinghua.edu.cn/simple

RUN apt update && apt install gcc g++ make vim \
    && pip install virtualenv && virtualenv nonebot2 && cd nonebot2 && source ./bin/activate  && pip install nb-cli \
    && cd /data && while timeout -k 70 60 bash -c 'git clone https://github.com/Kyomotoi/ATRI.git'; [ $? != 0 ];do echo "下载失败正在重试！(如多次重试不行建议手动下载仓库，修改dockerfile，copy到镜像里)" && sleep 2;done \
    && cd /data/ATRI && sed -i 's/pathlib>=1.0.1/#pathlib>=1.0.1/g' /data/ATRI/requirements.txt \
    && sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 's/enabled:\ true/enabled:\ false/g' -e 's/\"1234567890\"/\"1075129565\"/g' /data/ATRI/config.yml  \
    && pip install -r requirements.txt \
    && cd /data/ATRI && python main.py



