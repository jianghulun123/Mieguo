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
                "detour": "select"
            },
            {
                "tag": "local",
                "address": "h3://223.5.5.5/dns-query",
                "detour": "direct"
            },
            {
                "address": "rcode://success",
                "tag": "block"
            },
            {
                "tag": "dns_fakeip",
                "address": "fakeip"
            }
        ],
        "rules": [
            {
                "outbound": "any",
                "server": "local",
                "disable_cache": true
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
                "geosite": "cn",
                "server": "local"
            },
            {
                "geosite": "geolocation-!cn",
                "server": "remote"
            },
             {
                "geosite": "geolocation-!cn",             
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
          "independent_cache": true,
          "final": "remote"
        },
      "inbounds": [
    {
      "type": "tun",
      "inet4_address": "172.19.0.1/30",
      //"inet6_address": "fdfe:dcba:9876::1/126",
      "auto_route": true,
      "strict_route": true,
      "stack": "mixed",
      "sniff": true
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
        "hy2-sb",
        "tuic5-sb"
      ]
    },
    {
      "type": "vless",
      "tag": "vless-sb",
      "server": "2602:fa4f:200:433f:fdad:53b9:9ec1:48ca",
      "server_port": 3000,
      "uuid": "8d94b011-dab7-47d9-abe5-f1ec5121b74f",
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
          "public_key": "cx1KPOeu7ceqA_WxwQF6YD7XpX4cCsxenYilWKkKTkY",
          "short_id": "f518ac57"
        }
      }
    },
    {
        "type": "hysteria2",
        "tag": "hy2-sb",
        "server": "2602:fa4f:200:433f:fdad:53b9:9ec1:48ca",
        "server_port": 5000,
        "password": "8d94b011-dab7-47d9-abe5-f1ec5121b74f",
        "tls": {
            "enabled": true,
            "server_name": "www.bing.com",
            "insecure": true,
            "alpn": [
                "h3"
            ]
        }
    },
        {
            "type":"tuic",
            "tag": "tuic5-sb",
            "server": "2602:fa4f:200:433f:fdad:53b9:9ec1:48ca",
            "server_port": 20000,
            "uuid": "8d94b011-dab7-47d9-abe5-f1ec5121b74f",
            "password": "8d94b011-dab7-47d9-abe5-f1ec5121b74f",
            "congestion_control": "bbr",
            "udp_relay_mode": "native",
            "udp_over_stream": false,
            "zero_rtt_handshake": false,
            "heartbeat": "10s",
            "tls":{
                "enabled": true,
                "server_name": "www.bing.com",
                "insecure": true,
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
    "final": "select",
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
