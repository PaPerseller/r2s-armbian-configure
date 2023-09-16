#!/bin/sh

TMPDIR=$(mktemp -d) || exit 1
google_status=$(curl -I -4 -m 3 -o /dev/null -s -w %{http_code} http://www.google.com/generate_204)
[ "$google_status" -ne "204" ] && mirror="https://ghproxy.com/"
# geoip-cn.db
echo -e "\e[1;32mDownloading "$mirror"https://github.com/soffchen/sing-geoip/releases/latest/download/geoip-cn.db\e[0m"
curl --connect-timeout 60 -m 900 --ipv4 -kfSLo "$TMPDIR/geoip.db" ""$mirror"https://github.com/soffchen/sing-geoip/releases/latest/download/geoip-cn.db"
[ $? -ne 0 ] && rm -rf "$TMPDIR" && exit 1

# geosite.db
echo -e "\e[1;32mDownloading "$mirror"https://github.com/soffchen/sing-geosite/releases/latest/download/geosite.db\e[0m"
curl --connect-timeout 60 -m 900 --ipv4 -kfSLo "$TMPDIR/geosite.db" ""$mirror"https://github.com/soffchen/sing-geosite/releases/latest/download/geosite.db"
[ $? -ne 0 ] && rm -rf "$TMPDIR" && exit 1

cp -f "$TMPDIR"/* /usr/local/share/sing-box/
rm -rf "$TMPDIR"
