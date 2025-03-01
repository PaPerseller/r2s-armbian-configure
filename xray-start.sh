#!/bin/bash
# 添加 iproute 规则
ip rule add fwmark 0x40/0xc0 table 100
ip route add local 0.0.0.0/0 dev lo table 100
# 加载 nftables 规则
nft -f /usr/local/etc/xray/tproxy_ipv4.nft
