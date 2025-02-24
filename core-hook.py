#!/usr/bin/python3

import argparse
from os import path
import json

def main():
    # 解析参数
    parser = argparse.ArgumentParser()
    parser.add_argument('--v2raya-confdir', type=str, required=True)
    parser.add_argument('--stage', type=str, required=True)
    args = parser.parse_args()

    # 仅在 pre-start 阶段才修改配置文件
    if args.stage != 'pre-start':
        return

    # 读取配置文件内容
    conf_path = path.join(args.v2raya_confdir, 'config.json')
    with open(conf_path) as f:
        conf = json.loads(f.read())

    # 修改 outbound 中 tag 为 proxy 的 sockopt 项，增加并启用 tcpMptcp 和 tcpNoDelay, 需服务端也启用此项
    # 以下删除注释开启
    # for outbound in conf['outbounds']:
    #    if outbound['tag'] == 'proxy':
    #        if 'sockopt' in outbound['streamSettings']:
    #            outbound['streamSettings']['sockopt']['tcpMptcp'] = True
    #        else:
    #            outbound['streamSettings']['sockopt'] = {
    #                'tcpMptcp': True
    #            }

    # 修改 routing 中 domainMatcher 的值为 hybrid
    conf['routing']['domainMatcher'] = 'hybrid'

    # 将修改后的配置写回文件
    with open(conf_path, 'w') as f:
        f.write(json.dumps(conf, indent=4))

if __name__ == '__main__':
    main()
