#!/bin/bash

# 检查是否以root用户运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请以root用户运行此脚本"
    exit 1
fi

# 更新包列表并安装必要的软件包
apt update
apt install -y curl nano socat

# 安装Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# 安装acme.sh
curl https://get.acme.sh | sh
source ~/.bashrc

# 注册zerossl账户
read -p "请输入您的电子邮箱: " email
~/.acme.sh/acme.sh --register-account -m $email

# 输入域名并申请证书
read -p "请输入您的域名: " domain
~/.acme.sh/acme.sh --issue --standalone -d $domain

# 移动证书文件
mkdir ~/xray_cert
~/.acme.sh/acme.sh --install-cert -d $domain --ecc \
    --fullchain-file ~/xray_cert/xray.crt \
    --key-file ~/xray_cert/xray.key
chmod +r ~/xray_cert/xray.key

# 修改xray服务文件权限
sed -i 's/User=nobody/# User=nobody/' /etc/systemd/system/xray.service

# 生成UUID
uuid=$(cat /proc/sys/kernel/random/uuid)

# 获取用户输入或生成随机路径
read -p "请输入path路径（留空以生成随机路径）: " path
if [ -z "$path" ]; then
    path=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 16 | head -n 1)
fi

# 获取是否启用CDN选项
read -p "是否启用CDN？ (y/n): " use_cdn
if [[ "$use_cdn" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    alpn='["h2", "http/1.1"]'
    alpn_param='h2,http/1.1'
else
    alpn='["h3"]'
    alpn_param='h3'
fi

# 获取端口
read -p "请输入端口（如果要套CDN，最好选择443端口）: " port

# 配置Xray
cat <<EOF > /usr/local/etc/xray/config.json
{
    "inbounds": [
        {
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls",
                    "quic"
                ]
            },
            "port": $port,
            "listen": "0.0.0.0",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$uuid"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "splithttp",
                "security": "tls",
                "splithttpSettings": {
                    "path": "/$path",
                    "host": "$domain"
                },
                "tlsSettings": {
                    "rejectUnknownSni": true,
                    "minVersion": "1.3",
                    "alpn": $alpn,
                    "certificates": [
                        {
                            "ocspStapling": 3600,
                            "certificateFile": "/root/xray_cert/xray.crt",
                            "keyFile": "/root/xray_cert/xray.key"
                        }
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "tag": "direct",
            "protocol": "freedom"
        }
    ]
}
EOF

# 启动Xray
systemctl daemon-reload
systemctl start xray
systemctl enable xray


# 生成分享链接
share_link="vless://${uuid}@${domain}:${port}?encryption=none&security=tls&sni=${domain}&alpn=${alpn_param}&fp=chrome&type=splithttp&host=${domain}&path=/${path}#Xray"

echo "分享链接: $share_link"
