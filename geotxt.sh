#!/bin/sh

TMPDIR=$(mktemp -d) || exit 1
google_status=$(curl -I -4 -m 3 -o /dev/null -s -w %{http_code} http://www.google.com/generate_204)
[ "$google_status" -ne "204" ] && mirror="https://ghproxy.com/"
# geoip.txt
echo -e "\e[1;32mDownloading "$mirror"https://github.com/Hackl0us/GeoIP2-CN/raw/release/CN-ip-cidr.txt\e[0m"
curl --connect-timeout 60 -m 900 --ipv4 -kfSLo "$TMPDIR/geoip_cn.txt" ""$mirror"https://github.com/Hackl0us/GeoIP2-CN/raw/release/CN-ip-cidr.txt"
[ $? -ne 0 ] && rm -rf "$TMPDIR" && exit 1

# geosite.dat
echo -e "\e[1;32mDownloading "$mirror"https://raw.githubusercontent.com/QiuSimons/openwrt-mos/master/dat/geosite_cn.txt\e[0m"
curl --connect-timeout 60 -m 900 --ipv4 -kfSLo "$TMPDIR/geosite_cn.txt" ""$mirror"https://raw.githubusercontent.com/QiuSimons/openwrt-mos/master/dat/geosite_cn.txt"
[ $? -ne 0 ] && rm -rf "$TMPDIR" && exit 1

# geosite-nocn.dat
echo -e "\e[1;32mDownloading "$mirror"https://raw.githubusercontent.com/QiuSimons/openwrt-mos/master/dat/geosite_no_cn.txt\e[0m"
curl --connect-timeout 60 -m 900 --ipv4 -kfSLo "$TMPDIR/geosite_no_cn.txt" ""$mirror"https://raw.githubusercontent.com/QiuSimons/openwrt-mos/master/dat/geosite_no_cn.txt"
[ $? -ne 0 ] && rm -rf "$TMPDIR" && exit 1

cp -f "$TMPDIR"/* /etc/mosdns/rule/
rm -rf "$TMPDIR"
