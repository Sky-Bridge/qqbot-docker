# qqbot-docker
qq机器人儿

```bash
cd /data/qqbot/test && while timeout -k 70 60 bash -c 'git clone https://github.com/Sky-Bridge/qqbot-docker.git'; [ $? != 0 ];do echo "下载失败正在重试！" && sleep 2;done && cd qqbot-docker && chmod +x qqbot-install.sh
```
