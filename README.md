{
  "log": {
    "disabled": false,
    "level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "dns_proxy",
        "address": "https://dns.google/dns-query",
        "address_resolver": "dns_local",
        "detour": "select"
      },
      {
        "tag": "dns_direct",
        "address": "https://dns.alidns.com/dns-query",
        "address_resolver": "dns_local",
        "detour": "direct"
      },
      {
        "tag": "dns_local",
        "address": "223.5.5.5",
        "detour": "direct"
      },
      {
        "tag": "dns_block",
        "address": "rcode://success"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "dns_local"
      },
      {
        "geosite": "category-ads-all",
        "server": "dns_block",
        "disable_cache": true
      },
      {
        "geosite": "cn",
        "source_geoip": [
          "cn",
          "private"
        ],
        "server": "dns_direct"
      }
    ],
    "final": "dns_proxy",
    "strategy": "ipv4_only"
  },
  "route": {
    "geoip": {
      "download_url": "https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db",
      "download_detour": "select"
    },
    "geosite": {
      "download_url": "https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db",
      "download_detour": "select"
    },
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      },
      {
        "geosite": "cn",
        "geoip": [
          "cn",
          "private"
        ],
        "outbound": "direct"
      }
    ],
    "auto_detect_interface": true
  },
  "inbounds": [
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "::",
      "listen_port": 1080,
      "sniff": true,
      "set_system_proxy": false
    }
  ],
  "outbounds": [
    {
      "type": "hysteria2",
      "tag": "Hysteria2-9643",
      "server": "2602:fa4f:200:433f:fdad:53b9:9ec1:48ca",
      "server_port": 16372,
      "up_mbps": 100,
      "down_mbps": 100,
      "obfs": {
        "type": "hysteria2",
        "password": "83dcecd1-d40b-4d9d-9254-c7c338f5083f"
      },
      "password": "83dcecd1-d40b-4d9d-9254-c7c338f5083f",
      "tls": {
        "enabled": true,
        "insecure": true,
        "server_name": "6.16283684.xyz",
        "alpn": [
          "h3"
        ]
      }
    },
    {
      "type": "urltest",
      "tag": "auto",
      "outbounds": [
        "Hysteria2-9643"
      ],
      "url": "https://www.gstatic.com/generate_204",
      "interval": "1m",
      "tolerance": 50,
      "interrupt_exist_connections": false
    },
    {
      "type": "selector",
      "tag": "select",
      "outbounds": [
        "Hysteria2-9643", 
        "auto"
      ],
      "default": "auto",
      "interrupt_exist_connections": false
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    }
  ],
  "ntp": {
    "enabled": true,
    "server": "time.apple.com",
    "server_port": 123,
    "interval": "30m",
    "detour": "direct"
  }
}
