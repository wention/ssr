#!/bin/bash

KCP_URL="https://github.com/xtaci/kcptun/releases/download/v20171201/kcptun-linux-amd64-20171201.tar.gz"
KCP_SERVER="server_linux_amd64"
KCP_CLIENT="client_linux_amd64"

KCP_DIR="kcptun"
KCP_MODE="fast2"
KCP_CRYPT="none"
KCP_KEY="random_key"

KCP_REMOTE=
KCP_TARGET=
KCP_LOCAL=
INST_DIR="/opt"
INST_MODE="server"

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
        '-M'|'--inst-mode' )
            INST_MODE="$2"
            shift 2
            ;;
        '-t'|'--target' )
            KCP_TARGET="$2"
            shift 2
            ;;
        '-r'|'--remote' )
            KCP_REMOTE="$2"
            shift 2
            ;;
        '-l'|'--local' )
            KCP_LOCAL="$2"
            shift 2
            ;;
        '-c'|'--crypt' )
            KCP_CRYPT="$2"
            shift 2
            ;;
        '--mode' )
            KCP_MODE="$2"
            shift 2
            ;;
        '--key' )
            KCP_KEY="$2"
            shift 2
            ;;
        -*|--*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
    esac
done

echo "================================"
echo "Installing kcptun"
mkdir -p $INST_DIR/$KCP_DIR
cd $INST_DIR/$KCP_DIR
wget -c $KCP_URL

if [ "x$KCP_TARGET" == "x" -a "x$KCP_REMOTE" == "x" ];then
    echo "argument [target], [remote] muste be specify"
    exit 1
fi

if [ "x$KCP_LOCAL" == "x" ];then
    echo "argument [local] muste be specify"
    exit 1
fi

if [ "$INST_MODE" == "server" ];then
tar -xvf `basename $KCP_URL` $KCP_SERVER

# server logrun
cat > logrun.sh << EOF
#!/bin/bash
cd \`dirname \$0\`
eval \$(ps -ef | grep "[0-9] ./$KCP_SERVER" | awk '{print "kill "\$2}')
ulimit -n 512000
nohup ./$KCP_SERVER --crypt $KCP_CRYPT --key $KCP_KEY -t "$KCP_TARGET" -l "$KCP_LOCAL" -mode $KCP_MODE >> kcptun-$INST_MODE.log 2>&1 &
EOF

else [ "$INST_MODE" == "client" ]
tar -xvf `basename $KCP_URL` $KCP_CLIENT

# client logrun
cat > logrun.sh << EOF
#!/bin/bash
cd \`dirname \$0\

eval \$(ps -ef | grep "[0-9] ./$KCP_CLIENT" | awk '{print "kill "\$2}')
ulimit -n 512000
nohup ./$KCP_CLIENT --crypt $KCP_CRYPT --key $KCP_KEY -r "$KCP_REMOTE" -l "$KCP_LOCAL" -mode $KCP_MODE >> kcptun-$INST_MODE.log 2>&1 &
EOF
fi

chmod +x logrun.sh

echo "Installation done!"
