# Wcferry-RPC

基于 [WeChatFerry](https://github.com/lich0821/WeChatFerry) 开发的 Windows 微信 PC 端 Docker 容器化部署方案。本项目通过 Hook 方式将微信功能以 RPC 接口形式提供服务。

> **注意**：在 Linux 桌面环境下存在中文字符显示乱码的已知问题。由于本项目主要用于 RPC API 远程调用，这个显示问题不影响 API 的正常使用，因此暂不做处理。

## 功能特点

- 🐳 完整的 Docker 容器化部署方案
- 🔄 基于 WeChatFerry 的微信消息 Hook 实现
- 🌐 RPC 接口服务，方便二次开发
- 🖥️ 支持 RDP 远程登录管理

## 快速开始

### 1. 部署服务

```bash
# 克隆项目
git clone https://github.com/0xbitwild/Wcferry-RPC.git

# 进入项目目录
cd Wcferry-RPC

# 启动服务
docker compose up -d
```

### 2. 远程登录配置

通过 RDP 客户端连接到容器：

| 配置项 | 默认值 |
|--------|---------|
| 主机地址 | 容器所在主机IP |
| 端口 | 13389 |
| 用户名 | root |
| 密码 | Passw0rd |

### 3. 启动服务

1. 远程登录后，双击桌面的 `Start.desktop` 图标
2. 使用手机扫码登录微信
3. 登录成功后，RPC API 服务将在 10086 端口启动

## 自定义构建

如需自定义版本或配置，可以按以下步骤进行：

```bash
# 克隆项目
git clone https://github.com/0xbitwild/Wcferry-RPC.git

# 进入项目目录
cd Wcferry-RPC

# 配置版本信息
sed -i 's/VERSION=.*/VERSION=v39.4.0/g' .env                  # WeChatFerry 版本
sed -i 's/PYTHON_VERSION=.*/PYTHON_VERSION=3.12.4/g' .env     # Python 版本
sed -i 's/WECHAT_VERSION=.*/WECHAT_VERSION=3.9.12.17/g' .env  # 微信版本

# 配置远程登录信息
sed -i 's/USERNAME=.*/USERNAME=root/g' .env                    # RDP 用户名
sed -i 's/PASSWORD=.*/PASSWORD=Passw0rd/g' .env               # RDP 密码

# 构建镜像
docker compose build
```

### 手动安装步骤

由于 Wine 环境的特殊性，Python 和微信需要手动安装：

1. 通过 RDP 登录到容器
2. 双击 `Python3Setup.desktop` 安装 Python
3. 双击 `WeChatSetup.desktop` 安装微信

## 技术栈

- WeChatFerry：微信消息 Hook 实现
- Docker：容器化部署
- Wine：Windows 程序兼容层
- Python：运行环境
- RPC：接口服务

## 参考项目

- [WeChatFerry](https://github.com/lich0821/WeChatFerry) - 微信消息 Hook 框架
- [wechatbot-provider-windows](https://github.com/danni-cool/wechatbot-provider-windows) - Windows 微信机器人服务

## 许可证

本项目遵循 MIT 许可证
