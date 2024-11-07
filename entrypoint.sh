#! /bin/bash

set -e

if [ -f .env ]; then
    # shellcheck disable=SC1091
    source .env
else
    echo "Error: .env file not found"
    exit 1
fi

APP_DIR_PATH=/app
PACKAGES_DIR_PATH=/app/packages

PYTHON_PACKAGE="python-${PYTHON_VERSION}-amd64.exe"
WECHAT_PACKAGE="WeChatSetup-${WECHAT_VERSION}.exe"
WCFERRY_SCRIPT="wcferry_rpc.py"

cd "$(dirname "$0")" || exit 1

function gen_desktop_entry() {

    local username=$1

    home_dir_path=$(eval echo ~"$username")
    wine_system_path="${home_dir_path}/.wine/dosdevices"
    python_path="${wine_system_path}/c\:/users/${username}/AppData/Local/Programs/Python/Python312/python.exe"
    python_script_path="${wine_system_path}/z\:/app/${WCFERRY_SCRIPT}"

    mkdir -p "${home_dir_path}/Desktop"

    # 创建Python安装脚本
    if [ ! -f "${python_path}" ] && [ -f "${PACKAGES_DIR_PATH}/${PYTHON_PACKAGE}" ]; then
        cat > "${home_dir_path}/Desktop/Python3Setup.desktop" <<-EOF
[Desktop Entry]
Name=Python3Setup
Type=Application
Exec=env WINPREFIX="${home_dir_path}/.wine" xfce4-terminal -e "wine ${PACKAGES_DIR_PATH}/${PYTHON_PACKAGE}"
StartupNotify=true
Path=${APP_DIR_PATH}
Icon=package-x-generic
Terminal=false
EOF
    fi

    # 创建微信安装脚本
    if [ ! -f "${home_dir_path}/Desktop/WechatSetup.desktop" ] && [ -f "${PACKAGES_DIR_PATH}/${WECHAT_PACKAGE}" ]; then
        cat > "${home_dir_path}/Desktop/WechatSetup.desktop" << EOF
[Desktop Entry]
Name=WeChatSetup
Type=Application
Exec=env WINPREFIX="${home_dir_path}/.wine" xfce4-terminal -e "wine ${PACKAGES_DIR_PATH}/${WECHAT_PACKAGE}"
StartupNotify=true
Path=${APP_DIR_PATH}
Icon=package-x-generic
Terminal=false
EOF
    fi

    # 创建启动脚本
    if [ ! -f "${home_dir_path}/Desktop/Start.desktop" ]; then
        cat > "${home_dir_path}/Desktop/Start.desktop" << EOF
[Desktop Entry]
Name=Start
Type=Application
Exec=env WINPREFIX="${home_dir_path}/.wine" LANG=zh_CN.UTF-8 xfce4-terminal --working-directory="${APP_DIR_PATH}" -e "wine ${python_path} ${python_script_path}"
StartupNotify=true
Path=${APP_DIR_PATH}
Terminal=false
Icon=system-run
Terminal=false
EOF
    fi

    if [ ! -f "${home_dir_path}/Desktop/Cleanup.desktop" ]; then
        cat > "${home_dir_path}/Desktop/Cleanup.desktop" << EOF
[Desktop Entry]
Name=Cleanup
Type=Application
Exec=xfce4-terminal -e "/app/entrypoint.sh cleanup"
StartupNotify=true
Path=${APP_DIR_PATH}
Terminal=false
Icon=system-run
Terminal=false
EOF
    fi
}

function gen_xrdp_config() {

    local username=$1
    local password=$2

    if [ -z "$username" ] || [ -z "$password" ]; then
        username="admin"
        password="Passw0rd"
    fi

    if [ "$username" == "root" ]; then
        echo "root:$password" | chpasswd  # 设置root密码
        echo "xfce4-session" > /root/.xsession  # 设置xfce4-session为默认会话
    else
        useradd -m "$username"  # 创建用户
        echo "$username:$password" | chpasswd  # 设置用户密码
        adduser "$username" sudo  # 将用户添加到sudo组
        usermod -aG ssl-cert xrdp  # 将用户添加到xrdp组
        echo "xfce4-session" > /home/"$username"/.xsession  # 设置xfce4-session为默认会话
        chown "$username":"$username" /home/"$username"/.xsession  # 设置用户目录权限
    fi
}

function gen_fonts() {

    local username=$1

    home_dir_path=$(eval echo ~"$username")

    # 创建字体目录
    mkdir -p "${home_dir_path}/.wine/drive_c/windows/Fonts"
    # 复制字体文件
    cp /usr/share/fonts/truetype/wqy/* "${home_dir_path}/.wine/drive_c/windows/Fonts/"
}

function entrypoint() {
    # shellcheck disable=SC2153
    gen_xrdp_config "${USERNAME}" "${PASSWORD}"
    gen_desktop_entry "${USERNAME}"
    gen_fonts "${USERNAME}"

    # 删除 PID 文件
    [ -f /run/dbus/pid ] && rm -f /run/dbus/pid
    [ -f /var/run/xrdp/xrdp.pid ] && rm -f /var/run/xrdp/xrdp.pid
    [ -f /var/run/xrdp/xrdp-sesman.pid ] && rm -f /var/run/xrdp/xrdp-sesman.pid

    # 启动 D-Bus 守护进程
    mkdir -p /var/run/dbus
    dbus-daemon --system --fork

    # 等待 D-Bus 启动完成
    sleep 2

    # 启动 xrdp-sesman
    /usr/sbin/xrdp-sesman &

    # 等待 xrdp-sesman 启动完成
    sleep 2

    # 启动 xrdp
    exec /usr/sbin/xrdp -n
}

function cleanup() {

    home_dir_path=$(eval echo ~"$USERNAME")
    desktop_path="${home_dir_path}/Desktop"

    rm -rf /app/packages
    rm -rf /app/"WeChat Files"
    rm -rf "${desktop_path}/Python3Setup.desktop"
    rm -rf "${desktop_path}/WechatSetup.desktop"

    find /var/log -type f -name "*.log" | while read -r i; do
        echo "Cleaning up $i"
        rm -f "$i"
    done

    echo "Cleanup completed"
}


if [ "${1}" == "cleanup" ]; then
    cleanup
else
    entrypoint
fi
