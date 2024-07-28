#!/bin/bash

export LANG=en_US.UTF-8

# Color definitions
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN="\033[0m"

red(){
    echo -e "$RED$1$PLAIN"
}

green(){
    echo -e "$GREEN$1$PLAIN"
}

yellow(){
    echo -e "$YELLOW$1$PLAIN"
}

# System detection and package management commands
REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "fedora")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Fedora")
PACKAGE_UPDATE=("apt-get update" "apt-get update" "yum -y update" "yum -y update" "yum -y update")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "yum -y install")
PACKAGE_REMOVE=("apt -y remove" "apt -y remove" "yum -y remove" "yum -y remove" "yum -y remove")
PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove" "yum -y autoremove")

[[ $EUID -ne 0 ]] && red "Please run this script as root" && exit 1

CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')")

for i in "${CMD[@]}"; do
    SYS="$i" && [[ -n $SYS ]] && break
done

for ((int = 0; int < ${#REGEX[@]}; int++)); do
    [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && [[ -n $SYSTEM ]] && break
done

[[ -z $SYSTEM ]] && red "Your system is not supported!" && exit 1

if [[ -z $(type -P curl) ]]; then
    if [[ ! $SYSTEM == "CentOS" ]]; then
        ${PACKAGE_UPDATE[int]}
    fi
    ${PACKAGE_INSTALL[int]} curl
fi

realip(){
    ip=$(curl -s4m8 ip.gs -k) || ip=$(curl -s6m8 ip.gs -k)
}

inst_cert(){
    green "Choose your certificate option:"
    echo ""
    echo -e " ${GREEN}1.${PLAIN} Self-signed certificate ${YELLOW}(default)${PLAIN}"
    echo -e " ${GREEN}2.${PLAIN} Automatic certificate via Acme script"
    echo -e " ${GREEN}3.${PLAIN} Custom certificate path"
    echo ""
    read -rp "Enter your choice [1-3]: " certInput
    if [[ $certInput == 2 ]]; then
        cert_path="/etc/xray/cert/cert.crt"
        key_path="/etc/xray/cert/private.key"

        mkdir -p /etc/xray/cert
        chmod -R 777 /etc/xray/cert
        
        if [[ -f /etc/xray/cert/cert.crt && -f /etc/xray/cert/private.key ]] && [[ -s /etc/xray/cert/cert.crt && -s /etc/xray/cert/private.key ]] && [[ -f /etc/xray/cert/ca.log ]]; then
            domain=$(cat /etc/xray/cert/ca.log)
            green "Detected existing certificate for domain: $domain"
            hy_domain=$domain
        else
            read -p "Enter the domain for the certificate: " domain
            [[ -z $domain ]] && red "No domain entered, operation aborted!" && exit 1
            green "Entered domain: $domain" && sleep 1
            domainIP=$(dig @8.8.8.8 +time=2 +short "$domain" 2>/dev/null)
            if echo $domainIP | grep -q "network unreachable\|timed out" || [[ -z $domainIP ]]; then
                domainIP=$(dig @2001:4860:4860::8888 +time=2 aaaa +short "$domain" 2>/dev/null)
            fi
            if echo $domainIP | grep -q "network unreachable\|timed out" || [[ -z $domainIP ]] ; then
                red "Failed to resolve IP, please check the domain" 
                yellow "Try forced matching?"
                green "1. Yes, use forced matching"
                green "2. No, exit script"
                read -p "Enter choice [1-2]：" ipChoice
                if [[ $ipChoice == 1 ]]; then
                    yellow "Attempting forced matching to request domain certificate"
                else
                    red "Exiting script"
                    exit 1
                fi
            fi
            if [[ $domainIP == $ip ]]; then
                ${PACKAGE_INSTALL[int]} curl wget sudo socat openssl
                if [[ $SYSTEM == "CentOS" ]]; then
                    ${PACKAGE_INSTALL[int]} cronie
                    systemctl start crond
                    systemctl enable crond
                else
                    ${PACKAGE_INSTALL[int]} cron
                    systemctl start cron
                    systemctl enable cron
                fi
                curl https://get.acme.sh | sh -s email=$(date +%s%N | md5sum | cut -c 1-16)@gmail.com
                source ~/.bashrc
                bash ~/.acme.sh/acme.sh --upgrade --auto-upgrade
                bash ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
                if [[ -n $(echo $ip | grep ":") ]]; then
                    bash ~/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --listen-v6 --insecure
                else
                    bash ~/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --insecure
                fi
                bash ~/.acme.sh/acme.sh --install-cert -d ${domain} --key-file /etc/xray/cert/private.key --fullchain-file /etc/xray/cert/cert.crt --ecc
                if [[ -f /etc/xray/cert/cert.crt && -f /etc/xray/cert/private.key ]] && [[ -s /etc/xray/cert/cert.crt && -s /etc/xray/cert/private.key ]]; then
                    echo $domain > /etc/xray/cert/ca.log
                    sed -i '/--cron/d' /etc/crontab >/dev/null 2>&1
                    echo "0 0 * * * root bash /root/.acme.sh/acme.sh --cron -f >/dev/null 2>&1" >> /etc/crontab
                    green "Certificate obtained successfully! The certificate (cert.crt) and private key (private.key) files are saved in the /etc/xray/cert folder"
                    yellow "Certificate crt file path: /etc/xray/cert/cert.crt"
                    yellow "Private key file path: /etc/xray/cert/private.key"
                    hy_domain=$domain
                fi
            else
                red "The resolved IP of the domain does not match the real IP of the VPS"
                green "Recommendations:"
                yellow "1. Ensure CloudFlare cloud icon is off (DNS only)"
                yellow "2. Check DNS resolution settings to make sure the IP is the real IP of the VPS"
                yellow "3. If the script is outdated, post a screenshot on GitHub Issues, GitLab Issues, forums, or TG group for assistance"
                exit 1
            fi
        fi
    elif [[ $certInput == 3 ]]; then
        read -p "Enter the path of the public key file (crt): " cert_path
        yellow "Public key file path: $cert_path"
        read -p "Enter the path of the private key file (key): " key_path
        yellow "Private key file path: $key_path"
        read -p "Enter the certificate domain: " domain
        yellow "Certificate domain: $domain"
        hy_domain=$domain

        chmod +rw $cert_path
        chmod +rw $key_path
    else
        green "Using a self-signed certificate for Xray node"

        cert_path="/etc/xray/cert/cert.crt"
        key_path="/etc/xray/cert/private.key"
        mkdir -p /etc/xray/cert
        openssl ecparam -genkey -name prime256v1 -out /etc/xray/cert/private.key
        openssl req -new -x509 -days 36500 -key /etc/xray/cert/private.key -out /etc/xray/cert/cert.crt -subj "/CN=www.bing.com"
        chmod 777 /etc/xray/cert/cert.crt
        chmod 777 /etc/xray/cert/private.key
        hy_domain="www.bing.com"
    fi
}

# 安装 Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# 确认安装完成
if [ $? -ne 0 ]; then
    red "Xray 安装失败。"
    exit 1
fi

realip

inst_cert

# 生成 UUID
UUID=$(/usr/local/bin/xray uuid)

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
                    "host": "$hy_domain"
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
                            "certificateFile": "$cert_path",
                            "keyFile": "$key_path"
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
green "Xray 配置已生成并服务已启动。"
green "UUID: $UUID"
green "Path: /$PATH"
green "Port: 443"
