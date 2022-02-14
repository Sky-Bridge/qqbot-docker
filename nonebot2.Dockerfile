FROM  python:3.8

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
#    && apk add --no-cache gcc g++ make \
#    && pip install virtualenv && virtualenv nonebot2 && cd nonebot2 && source ./bin/activate  && pip install nb-cli

# pip install tensorflow -i https://pypi.tuna.tsinghua.edu.cn/simple

RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list \
    && apt update && apt install -y  gcc g++ make vim \
    && /usr/local/bin/python -m pip install --upgrade pip \
    && pip install virtualenv -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && virtualenv nonebot2


# && mkdir /data && cd /data && while timeout -k 70 60 bash -c 'git clone https://github.com/Kyomotoi/ATRI.git'; [ $? != 0 ];do echo "下载失败正在重试！(如多次重试不行建议手动下载仓库，修改dockerfile，copy到镜像里)" && sleep 2;done \
# && cd /data/ATRI && sed -i 's/pathlib>=1.0.1/#pathlib>=1.0.1/g' /data/ATRI/requirements.txt \
# && sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 's/enabled:\ true/enabled:\ false/g' -e 's/\"1234567890\"/\"1075129565\"/g' /data/ATRI/config.yml  \

RUN cd nonebot2 && /bin/bash -c "source ./bin/activate"  \
    && pip install nb-cli -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && nb driver install aiohttp -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && nb driver install httpx -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && nb driver install websockets -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && nb driver install quart -i https://pypi.tuna.tsinghua.edu.cn/simple
WORKDIR /data/ATRI
CMD [ "python main.py" ]

