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
      },
      {
        "tag": "remote",
        "address": "fakeip"
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
      },
      {
        "query_type": [
          "A",
          "AAAA"
        ],
        "server": "remote"
      }
    ],
    "fakeip": {
      "enabled": true,
      "inet4_range": "198.18.0.0/15",
      "inet6_range": "fc00::/18"
    },
    "independent_cache": true,
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
        "sing-box-reality-brutal"
      ]
    },
    {
      "type": "vless",
      "tag": "sing-box-reality-brutal",
      "uuid": "a6b55400-8813-487f-986b-8de7b1714021",
      "packet_encoding": "xudp",
      "server": "2602:fa4f:200:433f:fdad:53b9:9ec1:48ca",
      "server_port": 2000,
      "flow": "",
      "tls": {
        "enabled": true,
        "server_name": "itunes.apple.com",
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        },
        "reality": {
          "enabled": true,
          "public_key": "_54IRbhG5yBLbirZaOiyCIG9yB6TQ7nOrOA97bPlJjE",
          "short_id": "dbe2b58d87d0645c"
        }
      },
    "multiplex": {
        "enabled": true,
        "protocol": "h2mux",
        "max_connections": 1,
        "min_streams": 4,
        "padding": true,
        "brutal": {
            "enabled": true,
            "up_mbps": 50, //上行速度，windows，macos不会生效所以可随便写
            "down_mbps": 100 //下行速度，对应服务器的下行速度，当然可自行修改
        }
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
        "sing-box-reality-brutal"
      ],
      "url": "http://www.gstatic.com/generate_204",
      "interval": "1m",
      "tolerance": 50
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
        "geosite": "category-ads-all","outbound": "block"
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
        "outbound": "proxy"
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
