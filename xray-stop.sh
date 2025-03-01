#!/bin/bash
# 删除 iproute 规则
ip rule del fwmark 0x40/0xc0 table 100
ip route del local 0.0.0.0/0 dev lo table 100
# 清空 nftables 规则
nft flush ruleset
