#!/bin/bash

# 解析参数
for i in "$@"; do
  case $i in
    --v2raya-confdir=*)
      CONFDIR="${i#*=}"
      shift
      ;;
    --stage=*)
      STAGE="${i#*=}"
      shift
      ;;
    -*|--*)
      echo "Unknown option $i"
      shift
      ;;
    *)
      ;;
  esac
done

# 仅在 pre-start 阶段才修改配置文件
if [ "$STAGE" != "pre-start" ]; then
    exit 0
fi

# 配置文件路径
CONF_PATH="$CONFDIR/config.json"

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Please install jq and try again."
    exit 1
fi

# 修改配置文件
jq '
    # 修改 routing 中 domainMatcher 的值为 hybrid
    .routing.domainMatcher = "hybrid"

    # 修改 outbound 中 tag 为 proxy 的 sockopt 项，增加并启用 tcpMptcp ，需服务端也启用此项
    # 以下删除注释开启

    # | .outbounds |= map(
    #     if .tag == "proxy" then
    #         .streamSettings.sockopt.tcpMptcp = true
    #     else
    #         .
    #     end
    # )
    
' "$CONF_PATH" > "${CONF_PATH}.tmp" && mv "${CONF_PATH}.tmp" "$CONF_PATH"