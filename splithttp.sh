#!/bin/bash

# 安装 Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# 确认安装完成
if [ $? -ne 0 ]; then
    echo "Xray 安装失败。"
    exit 1
fi

# 提示输入域名
read -p "请输入您的域名: " DOMAIN

# 验证域名是否绑定本机 IP
LOCAL_IP=$(curl -s http://ipinfo.io/ip)
DOMAIN_IP=$(ping -c 1 $DOMAIN | grep PING | awk -F'[()]' '{print $2}')

if [ "$LOCAL_IP" != "$DOMAIN_IP" ]; then
    echo "域名未绑定到本机 IP。"
    exit 1
fi

# 安装 acme.sh
wget -O - https://get.acme.sh | sh

# 确保 .bashrc 被加载
source ~/.bashrc

# 升级 acme.sh 并启用自动升级
acme.sh --upgrade --auto-upgrade

# 申请证书
acme.sh --set-default-ca --server letsencrypt
acme.sh --issue -d $DOMAIN -w /home/vpsadmin/www/webpage --keylength ec-256 --force

# 安装证书
CERT_PATH="/etc/xray/cert"
mkdir -p $CERT_PATH
acme.sh --installcert -d $DOMAIN --cert-file $CERT_PATH/cert.crt --key-file $CERT_PATH/cert.key --fullchain-file $CERT_PATH/fullchain.crt --ecc

# 检查证书安装是否成功
if [ $? -ne 0 ]; then
    echo "证书安装失败。"
    exit 1
fi

# 生成 UUID
UUID=$(uuidgen)

# 生成随机 path 路径
PATH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)

# 生成 Xray 配置文件
CONFIG_PATH="/usr/local/etc/xray/config.json"
cat > $CONFIG_PATH <<EOF
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
            "port": 443,
            "listen": "0.0.0.0",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "splithttp",
                "security": "tls",
                "splithttpSettings": {
                    "path": "/$PATH",
                    "host": "$DOMAIN"
                },
                "tlsSettings": {
                    "rejectUnknownSni": true,
                    "minVersion": "1.3",
                    "alpn": [
                        "h3"
                    ],
                    "certificates": [
                        {
                            "ocspStapling": 3600,
                            "certificateFile": "$CERT_PATH/fullchain.crt",
                            "keyFile": "$CERT_PATH/cert.key"
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

# 重启 Xray 服务
systemctl start xray

# 显示配置信息
echo "Xray 配置已生成并服务已启动。"
echo "UUID: $UUID"
echo "Path: /$PATH"
echo "Port: 443"
