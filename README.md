port: 7890
allow-lan: true
mode: rule
log-level: info
unified-delay: true
global-client-fingerprint: chrome
ipv6: true
dns:
  enable: true
  listen: :53
  ipv6: true
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  default-nameserver: 
    - 223.5.5.5
    - 8.8.8.8
  nameserver:
    - https://dns.alidns.com/dns-query
    - https://doh.pub/dns-query
  fallback:
    - https://1.0.0.1/dns-query
    - tls://dns.google
  fallback-filter:
    geoip: true
    geoip-code: CN
    ipcidr:
      - 240.0.0.0/4

proxies:        
  - name: Reality-Brutal
    type: vless
    server: 89.213.182.72
    port: 10086
    uuid: d6297cca-451e-458e-850e-a455c6baab18
    network: tcp
    udp: true
    tls: true
    flow: 
    servername: itunes.apple.com
    client-fingerprint: chrome
    reality-opts:
      public-key: qB2Cv_UUXoH_PjDd6i5wwppcMvr3JyHL0mYAMSA8SmI
      short-id: 2eb906581ca49d89
    smux:
      enabled: true
      protocol: h2mux
      max-connections: 1
      min-streams: 4
      padding: true
      brutal-opts:
        enabled: true
        up: 50
        down: 100

proxy-groups:
  - name: 节点选择
    type: select
    proxies:
      - 自动选择
      - Reality-Brutal

  - name: 自动选择
    type: url-test #选出延迟最低的机场节点
    proxies:
      - Reality-Brutal
    url: "http://www.gstatic.com/generate_204"
    interval: 300
    tolerance: 50


rules:
    - GEOIP,LAN,DIRECT
    - GEOIP,CN,DIRECT
    - MATCH,节点选择
