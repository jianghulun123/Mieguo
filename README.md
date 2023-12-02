{
  "log": {
    "disabled": false,
    "level": "info",
    "timestamp": true
  },
    "dns": {
        "servers": [
            {
                "tag": "remote",
                "address": "https://8.8.8.8/dns-query",
                "address_resolver": "dns_resolver",               
                "detour": "select"
            },
            {
                "tag": "local",
                "address": "https://dns.alidns.com/dns-query",
                "address_resolver": "dns_resolver",
                "detour": "direct"
            },
            {
                "address": "rcode://refused",
                "tag": "block"
            },
            {
                "tag": "dns_fakeip",
                "address": "fakeip"
            },
            {
                "tag": "dns_resolver",
                "address": "223.5.5.5",
                "detour": "direct"
            }
        ],
        "rules": [
            {
                "outbound": [
                    "any"
                ],
                "server": "dns_resolver"
            },
            {
                "clash_mode": "Global",
                "server": "remote"
            },
            {
                "clash_mode": "Direct",
                "server": "local"
            },
            {
                "geosite": [
                    "geolocation-!cn"
                ],
                "server": "remote"
            },
             {
                "geosite": [
                    "geolocation-!cn"
                ],             
                "query_type": [
                    "A",
                    "AAAA"
                ],
                "server": "dns_fakeip"
            }
          ],
           "fakeip": {
           "enabled": true,
           "inet4_range": "198.18.0.0/15",
           "inet6_range": "fc00::/18"
         },
          "independent_cache": true
        },
      "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "inet4_address": "172.19.0.1/30",
      //"inet6_address": "fdfe:dcba:9876::1/126",
      "auto_route": true,
      "strict_route": true,
      "stack": "mixed",
      "sniff": true,
      "sniff_override_destination": false
    }
  ],
  "experimental": {
    "clash_api": {
      "external_controller": "127.0.0.1:9090",
      "external_ui": "ui",
      "external_ui_download_url": "",
      "external_ui_download_detour": "",
      "secret": "",
      "default_mode": "Rule",
      "store_mode": true,
      "store_selected": true,
      "store_fakeip": true
    }
  },
  "outbounds": [
    {
      "tag": "select",
      "type": "selector",
      "default": "auto",
      "outbounds": [
        "auto",
        "vless-sb",
        "vmess-sb",
        "hy2-sb",
        "tuic5-sb"
      ]
    },
    {
      "type": "vless",
      "tag": "vless-sb",
      "server": "7.16283684.xyz",
      "server_port": 2000,
      "uuid": "24a0c1e4-8887-4e07-b4f4-8d310471feba",
      "flow": "xtls-rprx-vision",
      "tls": {
        "enabled": true,
        "server_name": "www.yahoo.com",
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        },
      "reality": {
          "enabled": true,
          "public_key": "PLYfNojrqD0mdSQ3GqNdQ17nD68Ew39sZF-8ZMYCGA8",
          "short_id": "c30ec2a2"
        }
      }
    },
{
            "server": "7.16283684.xyz",
            "server_port": 3000,
            "tag": "vmess-sb",
            "tls": {
                "enabled": false,
                "server_name": "7.16283684.xyz",
                "insecure": false,
                "utls": {
                    "enabled": true,
                    "fingerprint": "chrome"
                }
            },
            "transport": {
                "headers": {
                    "Host": [
                        "7.16283684.xyz"
                    ]
                },
                "path": "24a0c1e4-8887-4e07-b4f4-8d310471feba-vm",
                "type": "ws"
            },
            "type": "vmess",
            "security": "auto",
            "uuid": "24a0c1e4-8887-4e07-b4f4-8d310471feba"
        },
    {
        "type": "hysteria2",
        "tag": "hy2-sb",
        "server": "7.16283684.xyz",
        "server_port": 4000,
        "up_mbps": 50, 
        "down_mbps": 100,
        "password": "24a0c1e4-8887-4e07-b4f4-8d310471feba",
        "tls": {
            "enabled": true,
            "server_name": "7.16283684.xyz",
            "insecure": false,
            "alpn": [
                "h3"
            ]
        }
    },
        {
            "type":"tuic",
            "tag": "tuic5-sb",
            "server": "7.16283684.xyz",
            "server_port": 20001,
            "uuid": "24a0c1e4-8887-4e07-b4f4-8d310471feba",
            "password": "24a0c1e4-8887-4e07-b4f4-8d310471feba",
            "congestion_control": "bbr",
            "udp_relay_mode": "native",
            "udp_over_stream": false,
            "zero_rtt_handshake": false,
            "heartbeat": "10s",
            "tls":{
                "enabled": true,
                "server_name": "7.16283684.xyz",
                "insecure": false,
                "alpn": [
                    "h3"
                ]
            }
        },
    {
      "tag": "direct",
      "type": "direct"
    },
    {
      "tag": "block",
      "type": "block"
    },
    {
      "tag": "dns-out",
      "type": "dns"
    },
    {
      "tag": "auto",
      "type": "urltest",
      "outbounds": [
        "vless-sb",
        "vmess-sb",
        "hy2-sb",
        "tuic5-sb"
      ],
      "url": "https://cp.cloudflare.com/generate_204",
      "interval": "1m",
      "tolerance": 50,
      "interrupt_exist_connections": false
    }
  ],
  "route": {
      "geoip": {
      "download_url": "https://mirror.ghproxy.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.db",
      "download_detour": "select"
    },
    "geosite": {
      "download_url": "https://mirror.ghproxy.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.db",
      "download_detour": "select"
    },
    "auto_detect_interface": true,
    "rules": [
      {
        "outbound": "dns-out",
        "protocol": "dns"
      },
      {
        "clash_mode": "Direct",
        "outbound": "direct"
      },
      {
        "clash_mode": "Global",
        "outbound": "select"
      },
      {
        "geosite": "cn",
        "geoip": [
          "cn",
          "private"
        ],
        "outbound": "direct"
      },
      {
        "geosite": "geolocation-!cn",
        "outbound": "select"
      }
    ]
  },
    "ntp": {
    "enabled": true,
    "server": "time.apple.com",
    "server_port": 123,
    "interval": "30m",
    "detour": "direct"
  }
}
