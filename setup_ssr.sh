#!/bin/bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SSR_GIT="https://github.com/shadowsocksrr/shadowsocksr.git"
SSR_GIT_BRANCH="manyuser"
SSR_DIR='ssr'

SERVER_IP=
INST_DIR="/opt"
INST_MODE="server"

# SSR params
SSR_PORT=22157
SSR_METHOD=
SSR_OBFS=
SSR_PROTO=
SSR_PASS=

for opt in "$@"
do
    case "$opt" in
        '-h'|'--help' )
            usage
            exit 1
            ;;
        '-s'|'--server-ip' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            SERVER_IP="$2"
            shift 2
            ;;
        '-d'|'--inst-dir' )
            INST_DIR="$2"
            shift 2
            ;;
        '-p'|'--server-port' )
            SSR_PORT="$2"
            shift 2
            ;;
        '-m'|'--method' )
            SSR_METHOD="$2"
            shift 2
            ;;
        '--obfs' )
            SSR_OBFS="$2"
            shift 2
            ;;
        '--proto' )
            SSR_PROTO="$2"
            shift 2
            ;;
        '--pass' )
            SSR_PASS="$2"
            shift 2
            ;;
        -*|--*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
    esac
done

echo "================================"
echo "Installing udp2raw"

# clone git repo
git clone $SSR_GIT $INST_DIR/$SSR_DIR

# setup ssr
cd $INST_DIR/$SSR_DIR
bash initmudbjson.sh

sed -i "s/SERVER_PUB_ADDR = .\+/SERVER_PUB_ADDR = \'"${SERVER_IP}"\'/g" userapiconfig.py
python mujson_mgr.py -a -p ${SSR_PORT} -m $SSR_METHOD -o $SSR_OBFS -O $SSR_PROTO -k $SSR_PASS

echo "Installing done!"
