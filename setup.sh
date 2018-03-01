#!/bin/bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SETUP_SSR=$PWD/setup_ssr.sh
SETUP_KCPTUN=$PWD/setup_kcptun.sh
SETUP_UDP2RAW=$PWD/setup_udp2raw.sh

SERVER_IP=
INST_DIR="/opt"
INST_MODE="server"

PASS="random_key"

# SSR params
SSR_PORT=22157
SSR_METHOD="aes-128-ctr"
SSR_OBFS="tls1.2_ticket_auth_compatible"
SSR_PROTO="auth_aes128_md5"

KCP_PORT=4000
UDP2RAW_PORT=4001

DISABLE_KCPTUN=0
DISABLE_UDP2RAW=0

usage() {
    echo "Usage: $PROGNAME [OPTIONS] [FILE]"
    echo "  This script is ~."
    echo
    echo "Options:"
    echo "  -h, --help"
    echo "      --version"
    echo "  -a, --long-a ARG"
    echo "  -b, --long-b [ARG]"
    echo "  -c, --check"
    echo
    exit 1
}

for opt in "$@"
do
    case "$opt" in
        '-h'|'--help' )
            usage
            exit 1
            ;;
        '-d'|'--inst-dir' )
            INST_DIR="$2"
            shift 2
            ;;
        '-s'|'--server-ip' )
            SERVER_IP="$2"
            shift 2
            ;;
        '--ssr-port' )
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
            PASS="$2"
            shift 2
            ;;
        '--disable-kcptun' )
            DISABLE_KCPTUN=1
            shift 2
            ;;
        '--kcp-port' )
            KCP_PORT="$2"
            shift 2
            ;;
        '--disable-udp2raw' )
            DISABLE_UDP2RAW=1
            shift 2
            ;;
        '--udp2raw-port' )
            UDP2RAW_PORT="$2"
            shift 2
            ;;
        -*|--*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
    esac
done


# setup shadowsocksr server
$SETUP_SSR --server-ip $SERVER_IP --server-port $SSR_PORT --method $SSR_METHOD --obfs $SSR_OBFS --proto $SSR_PROTO --pass $PASS --inst-dir $INST_DIR

if [ $DISABLE_KCPTUN -eq 0 ]; then
    $SETUP_KCPTUN --inst-dir $INST_DIR --inst-mode server -t "127.0.0.1:$SSR_PORT" -l ":$KCP_PORT" --key $PASS
fi

if [ $DISABLE_UDP2RAW -eq 0 ]; then
    $SETUP_UDP2RAW --inst-dir $INST_DIR --inst-mode server -r "127.0.0.1:$KCP_PORT" -l "0.0.0.0:$UDP2RAW_PORT" --key $PASS
fi
