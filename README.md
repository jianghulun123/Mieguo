{
  "log": {
    "level": "debug",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "proxyDns",
        "address": "8.8.8.8",
        "detour": "proxy"
      },
      {
        "tag": "localDns",
        "address": "https://223.5.5.5/dns-query",
        "detour": "direct"
      },
      {
        "tag": "block",
        "address": "rcode://success"
      }
    ],
    "rules": [
      {
        "domain": [
          "ghproxy.com",
          "cdn.jsdelivr.net",
          "testingcf.jsdelivr.net"
        ],
        "server": "localDns"
      },
      {
        "geosite": "category-ads-all",
        "server": "block"
      },
      {
        "outbound": "any",
        "server": "localDns",
        "disable_cache": true
      },
      {
        "geosite": "cn",
        "server": "localDns"
      },
      {
        "clash_mode": "direct",
        "server": "localDns"
      },
      {
        "clash_mode": "global",
        "server": "proxyDns"
      },
      {
        "geosite": "geolocation-!cn",
        "server": "proxyDns"
      }
    ],
    "strategy": "ipv4_only"
  },
  "inbounds": [
    {
      "type": "tun",
      "inet4_address": "172.19.0.1/30",
      "mtu": 9000,
      "auto_route": true,
      "strict_route": true,
      "sniff": true,
      "endpoint_independent_nat": false,
      "stack": "system",
      "platform": {
        "http_proxy": {
          "enabled": true,
          "server": "127.0.0.1",
          "server_port": 2080
        }
      }
    },
    {
      "type": "mixed",
      "listen": "127.0.0.1",
      "listen_port": 2080,
      "sniff": true,
      "users": []
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "type": "selector",
      "outbounds": [
        "auto",
        "direct",
        "🇩🇰 27eNDKbn_hysteria2",
        "ygkkk-vm-argo"
      ]
    },
    {
      "tag": "🌏 !cn",
      "type": "selector",
      "outbounds": [
        "direct",
        "🇩🇰 27eNDKbn_hysteria2",
        "ygkkk-vm-argo"
      ]
    },
    {
      "tag": "auto",
      "type": "urltest",
      "outbounds": [
        "🇩🇰 27eNDKbn_hysteria2",
        "ygkkk-vm-argo"
      ],
      "url": "http://www.gstatic.com/generate_204",
      "interval": "1m",
      "tolerance": 50
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    },
    {
      "type": "block",
      "tag": "block"
    },
    {
      "tag": "🇩🇰 27eNDKbn_hysteria2",
      "type": "hysteria2",
      "server": "mie.16283684.xyz",
      "server_port": 14428,
      "password": "7e28b928-f066-4ca5-966d-e613e9c21f05",
      "up_mbps": 10,
      "down_mbps": 100,
      "tls": {
        "enabled": true,
        "server_name": "mie.16283684.xyz",
        "alpn": [
          "h3"
        ]
      }
    },
    {
      "tag": "ygkkk-vm-argo",
      "type": "vmess",
      "server": "www.visa.com",
      "server_port": 443,
      "uuid": "12c99a8d-d97b-4667-85b8-6fd139c0ce19",
      "security": "auto",
      "alter_id": 0,
      "packet_encoding": "xudp",
      "tls": {
        "enabled": true,
        "insecure": true,
        "server_name": "hobby-scored-tampa-heel.trycloudflare.com"
      },
      "transport": {
        "type": "ws",
        "headers": {
          "Host": "hobby-scored-tampa-heel.trycloudflare.com"
        },
        "path": "12c99a8d-d97b-4667-85b8-6fd139c0ce19-vm"
      }
    }
  ],
  "route": {
    "auto_detect_interface": true,
    "final": "proxy",
    "geoip": {
      "download_url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.db",
      "download_detour": "direct"
    },
    "geosite": {
      "download_url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.db",
      "download_detour": "direct"
    },
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      },
      {
        "network": "udp",
        "port": 443,
        "outbound": "block"
      },
      {
        "geosite": "category-ads-all",
        "outbound": "block"
      },
      {
        "clash_mode": "direct",
        "outbound": "direct"
      },
      {
        "clash_mode": "global",
        "outbound": "proxy"
      },
      {
        "domain": [
          "clash.razord.top",
          "yacd.metacubex.one",
          "yacd.haishan.me",
          "d.metacubex.one"
        ],
        "outbound": "direct"
      },
      {
        "geosite": "geolocation-!cn",
        "outbound": "🌏 !cn"
      },
      {
        "geoip": [
          "private",
          "cn"
        ],
        "outbound": "direct"
      },
      {
        "geosite": "cn",
        "outbound": "direct"
      }
    ]
  },
  "experimental": {
    "clash_api": {
      "external_controller": "127.0.0.1:9090",
      "external_ui_download_url": "",
      "external_ui_download_detour": "",
      "external_ui": "ui",
      "secret": "",
      "default_mode": "rule",
      "store_selected": true,
      "cache_file": "",
      "cache_id": ""
    }
  }
}
