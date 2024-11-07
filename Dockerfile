# 选择一个精简的基础Linux镜像
FROM ubuntu:20.04

ARG VERSION
ARG PYTHON_VERSION
ARG WECHAT_VERSION

LABEL version=${VERSION} \
      python_version=${PYTHON_VERSION} \
      wechat_version=${WECHAT_VERSION}

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    VERSION=${VERSION} \
    PYTHON_VERSION=${PYTHON_VERSION} \
    WECHAT_VERSION=${WECHAT_VERSION}

# 升级镜像软件包到最新版，并安装所需软件
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common \
    unzip \
    wget \
    netcat-openbsd \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    xrdp \
    xorg \
    dbus-x11 \
    x11-xserver-utils \
    fonts-wqy-zenhei && \
    dpkg --add-architecture i386 && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources && \
    apt-get update && \
    apt-get install -y --install-recommends winehq-stable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN mkdir -p packages sdk logs && \
    if [ ! -f packages/python-${PYTHON_VERSION}-amd64.exe ]; then \
        wget -O packages/python-${PYTHON_VERSION}-amd64.exe https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe; \
    fi && \
    if [ ! -f packages/WeChatSetup-${WECHAT_VERSION}.exe ]; then \
        wget -O packages/WeChatSetup-${WECHAT_VERSION}.exe https://github.com/lich0821/WeChatFerry/releases/download/${VERSION}/WeChatSetup-${WECHAT_VERSION}.exe; \
    fi && \
    if [ ! -f packages/${VERSION}.zip ]; then \
        wget -O packages/${VERSION}.zip https://github.com/lich0821/WeChatFerry/releases/download/${VERSION}/${VERSION}.zip; \
    fi && \
    unzip -o packages/${VERSION}.zip -d sdk/

# 开放服务端口
EXPOSE 3389
EXPOSE 10086
EXPOSE 10087

# 启动 xrdp 和 XFCE 桌面环境
ENTRYPOINT ["/app/entrypoint.sh"]
