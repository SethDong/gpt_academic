# 此Dockerfile适用于“无本地模型”的迷你运行环境构建
# 如果需要使用chatglm等本地模型或者latex运行依赖，请参考 docker-compose.yml
# - 如何构建: 先修改 `config.py`， 然后 `docker build -t gpt-academic . `
# - 如何运行(Linux下): `docker run --rm -it --net=host gpt-academic `
# - 如何运行(其他操作系统，选择任意一个固定端口50923): `docker run --rm -it -e WEB_PORT=50923 -p 50923:50923 gpt-academic `
FROM python:3.11

# 更新包列表并安装 TeX Live 及其依赖
RUN apt-get update && \
    apt-get install -y texlive-full && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# 进入工作路径（必要）
WORKDIR /gpt

# 安装大部分依赖，利用Docker缓存加速以后的构建 （以下两行，可以删除）
COPY requirements.txt ./
RUN pip3 install -r requirements.txt


# 装载项目文件，安装剩余依赖（必要）
COPY . .
RUN pip3 install -r requirements.txt


# 非必要步骤，用于预热模块（可以删除）
RUN python3  -c 'from check_proxy import warm_up_modules; warm_up_modules()'


# 启动（必要）
CMD ["python3", "-u", "main.py"]
