#!/bin/bash


docker build -f nonebot2.Dockerfile -t nonebot2:v1 .
docker run -dit --name nonebot -v /data/qqbot/nonebot2:/nonebot2 nonebot2:v1