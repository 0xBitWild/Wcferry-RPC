# Wcferry-RPC

这是一个将Windows微信PC端容器化安装，并基于 [WeChatFerry](https://github.com/lich0821/WeChatFerry) 的Hook方式将RPC暴露出来的API服务。

## 直接使用

服务端部署
```bash

# 克隆项目
git clone https://github.com/0xbitwild/Wcferry-RPC.git

# 进入项目目录
cd Wcferry-RPC

# 启动服务
docker compose up -d

```

通过RDP登录到容器
- **主机**：容器所在主机IP
- **默认端口**：13389
- **默认用户名**：root
- **默认密码**：Passw0rd

启动RPC API服务
- Step1:双击桌面图标：Start.desktop
- Step2: 扫码登录微信后，即可使用API，默认RPC API端口：10086

## 自行构建

```bash

# 克隆项目
git clone https://github.com/0xbitwild/Wcferry-RPC.git

# 进入项目目录
cd Wcferry-RPC

# 修改版本号
sed -i 's/VERSION=.*/VERSION=v39.2.4/g' .env                  # Wcferry版本号，根据需要修改
sed -i 's/PYTHON_VERSION=.*/PYTHON_VERSION=3.12.4/g' .env     # Python版本号，根据需要修改
sed -i 's/WECHAT_VERSION=.*/WECHAT_VERSION=3.9.10.27/g' .env  # 微信版本号，根据需要修改

# 修改RDP远程登录账户
sed -i 's/USERNAME=.*/USERNAME=root/g' .env                    # RDP用户名，根据需要修改
sed -i 's/PASSWORD=.*/PASSWORD=Passw0rd/g' .env                # RDP密码，根据需要修改

# 构建镜像
docker compose build

```

由于Wine环境下的微信和Pyhon3，暂时无法自动化安装，需要通过RDP登录到容器，完成手工安装：
- **Python安装图标**： Python3Setup.desktop
- **微信安装图标**： WeChatSetup.desktop

## 参考

- [WeChatFerry](https://github.com/lich0821/WeChatFerry)
- [wechatbot-provider-windows](https://github.com/danni-cool/wechatbot-provider-windows)
