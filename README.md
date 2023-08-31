 # r2s-armbian-configure
 由于目前网上关于 R2S 使用 armbian 并将其作为旁路网关的内容较为分散且稀少，故将本人配置过程记录以作备份和参考。目前方案为 mosdns 分流 + Adguard home 国内域名解析 + v2raya/sing-box 代理。
 
 ## armbian 的安装与基础配置
 以下内容基于 Armbian 23.05.1 Bookworm CLI 版本，默认在 root 用户下操作。

将烧录了 armbian 系统的 tf 卡插入机器通电启动，不会像 openwrt 一样表现为 sys 红灯闪烁直至系统启动完毕红灯常亮，而是红灯持续闪烁且 LAN、WAN 两口指示灯常关。此时需在主路由器上查看 armbian 被分配的内网地址且通过 ssh 进入进行初始化，并将网关与 dns 地址设为主路由地址。

### 更换国内源
1、以清华源为例编辑  /etc/apt/sources.list 文件
```
nano /etc/apt/sources.list
```
注释官方源并添加清华源
```
deb https://mirrors.tuna.tsinghua.edu.cn/debian bookworm main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian bookworm-updates main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian bookworm-backports main contrib non-free non-free-firmware
#deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
```
2、编辑 /etc/apt/sources.list.d/armbian.list 文件
```
nano /etc/apt/sources.list.d/armbian.list
```
注释官方源并添加清华源
```
#deb [signed-by=/usr/share/keyrings/armbian.gpg] http://apt.armbian.com bookworm main bookworm-utils bookworm-desktop
deb [signed-by=/usr/share/keyrings/armbian.gpg] https://mirrors.tuna.tsinghua.edu.cn/armbian bookworm main bookworm-utils bookworm-desktop
```
3、更新软件列表
```
apt update
```
### 更改 cpu 调度模式为 schedutil
系统默认模式为 onedemand，且在 armbian-config 中更改模式不生效。
编辑文件 `nano /etc/default/cpufrequtils` 并修改为
```
ENABLE=true
MIN_SPEED=816000
MAX_SPEED=1296000
GOVERNOR=schedutil
```
重启 cpufrequtils 服务
```
systemctl daemon-reload
systemctl restart cpufrequtils
```

## 安装 AdGuard Home
使用官方一键脚本
```
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
```
由于稍后使用 mosdns 进行前置分流，此时配置 AdGuard Home 的 dns 服务监听端口不要使用 53 端口。

## 安装并配置 mosdns

### 下载
```
wget https://github.com/IrineSistiana/mosdns/releases/download/v5.1.3/mosdns-linux-arm64.zip
```

### 检查 53 端口占用并停用相关服务
```
#检查占用
lsof -i :53

#若有其他服务占用则停用
systemctl stop 服务名

#关闭占用服务的开机自启
systemctl disable 服务名
```
重新检查 53 端口占用

### 安装
```
apt install zip -y
unzip -o -d mosdns mosdns-linux-arm64.zip
mkdir /etc/mosdns
mv /root/mosdns/mosdns /usr/bin/
chmod +x /usr/bin/mosdns
mosdns service install -d /usr/bin -c /etc/mosdns/config.yaml
```
配置文件及规则文件可自行配置，也可参考使用此项目 mosdns 目录中相关文件并放入 /etc/mosdns 中。config.yaml 中 forward_local 地址端口应指向 AdguardHome 监听端口。

启动并加入开机自启
```
mosdns service start
systemctl enable mosdns
```
## 代理方案一：安装并配置 v2raya
根据官方安装项目安装 xray：https://github.com/XTLS/Xray-install

根据 v2raya 文档安装 v2raya: https://v2raya.org/en/docs/prologue/installation/debian/

启动并加入开机自启
```
systemctl start v2raya.service
systemctl enable v2raya.service
```
按照下图配置 v2raya  
![](v2raya.png)

RoutingA 配置可参考： https://raw.githubusercontent.com/PaPerseller/chn-iplist/master/v2rayA.txt

## 代理方案二：安装并配置 sing-box
可使用 [KoinuDayo/Sing-box-Install](https://github.com/KoinuDayo/Sing-box-Install) 项目脚本安装 sing-box

TUN 模式下透明代理参考配置文件： https://raw.githubusercontent.com/PaPerseller/chn-iplist/master/sing-box_tungate.json

## 一些额外设置
### 自动更新 xray 和 mosdns 资源文件

新建脚本目录并上传本项目中 geodat.sh、geotxt.sh、geodb.sh
```
mkdir /root/script
```
编辑定时任务 `nano /etc/crontab` 将以下两行加入
```
0  2    * * *   root    /root/script/geodat.sh
0  3    * * *   root    /root/script/geotxt.sh
0  4    * * *   root    /root/script/geodb.sh
```
### iptables 防火墙（可能有误）
```
iptables -t nat -A PREROUTING -p tcp --dport 22 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 53 -j ACCEPT
iptables -t nat -A PREROUTING -p udp --dport 53 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 3000 -j ACCEPT
iptables -t nat -A PREROUTING -d armbian主机ip地址 -p tcp --dport 80 -j ACCEPT
```
保存防火墙设置
```
apt install iptables-persistent -y
netfilter-persistent save
netfilter-persistent reload
```

## PS.
系统默认最高频率 1296MHz，目前适配 R2S 的多数 openwrt 系统可超频至 1512MHz 稳定运行。armbian 下 coremark 多核分数为 16933 ，相比 openwrt 下低了近 16% 。但在 armbian 下超频需更改 dtb 文件并重新编译内核，且相差的极限性能对于旁路网关来说感知不大。

此套旁路网关透明代理方案与在 openwrt 中使用 mosdns + Adguard home + passwall 方案，cpu 和内存占用几乎一致。

内核中存在 pwm-fan 模块，难以启用。LED 灯控制无有效参考资源难以启用。

本流程也可用于非 armbian 的 Linux 系统搭建旁路网关环境。

## 参考 & 致谢
* https://blog.haibara.cn/archives/70
* https://www.youtube.com/watch?v=6-OCKzW381Q&t=1577s
* https://github.com/sbwml/luci-app-mosdns 项目中的 geo-update 脚本
* https://github.com/Hackl0us/GeoIP2-CN
* https://github.com/QiuSimons/openwrt-mos/
* https://github.com/Loyalsoldier/v2ray-rules-dat