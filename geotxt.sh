#!/bin/sh

TMPDIR=$(mktemp -d) || exit 1
google_status=$(curl -I -4 -m 3 -o /dev/null -s -w %{http_code} http://www.google.com/generate_204)
[ "$google_status" -ne "204" ] && mirror="https://hub.gitmirror.com/"
# geoip.txt
echo -e "\e[1;32mDownloading "$mirror"https://raw.githubusercontent.com/PaPerseller/chn-iplist/master/chnroute-ipv4.txt\e[0m"
curl --connect-timeout 60 -m 900 --ipv4 -kfSLo "$TMPDIR/geoip_cn.txt" ""$mirror"https://raw.githubusercontent.com/PaPerseller/chn-iplist/master/chnroute-ipv4.txt"
[ $? -ne 0 ] && rm -rf "$TMPDIR" && exit 1

# geosite_cn.txt
echo -e "\e[1;32mDownloading "$mirror"https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/china-list.txt\e[0m"
curl --connect-timeout 60 -m 900 --ipv4 -kfSLo "$TMPDIR/geosite_cn.txt" ""$mirror"https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/china-list.txt"
[ $? -ne 0 ] && rm -rf "$TMPDIR" && exit 1

# apple-cn.txt
echo -e "\e[1;32mDownloading "$mirror"https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/apple-cn.txt\e[0m"
curl --connect-timeout 60 -m 900 --ipv4 -kfSLo "$TMPDIR/apple_cn.txt" ""$mirror"https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/apple-cn.txt"
[ $? -ne 0 ] && rm -rf "$TMPDIR" && exit 1

# google-cn.txt
echo -e "\e[1;32mDownloading "$mirror"https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/google-cn.txt\e[0m"
curl --connect-timeout 60 -m 900 --ipv4 -kfSLo "$TMPDIR/google_cn.txt" ""$mirror"https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/google-cn.txt"
[ $? -ne 0 ] && rm -rf "$TMPDIR" && exit 1

# geosite-nocn.txt
echo -e "\e[1;32mDownloading "$mirror"https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt\e[0m"
curl --connect-timeout 60 -m 900 --ipv4 -kfSLo "$TMPDIR/geosite_no_cn.txt" ""$mirror"https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt"
[ $? -ne 0 ] && rm -rf "$TMPDIR" && exit 1

cp -f "$TMPDIR"/* /etc/mosdns/rule
rm -rf "$TMPDIR"