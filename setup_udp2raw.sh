#!/bin/bash

UDP2RAW_URL="https://github.com/wangyu-/udp2raw-tunnel/releases/download/20180225.0/udp2raw_binaries.tar.gz"
UDP2RAW_SERVER="udp2raw_amd64"
UDP2RAW_CLIENT="udp2raw_amd64"

UDP2RAW_DIR="udp2raw"
UDP2RAW_MODE="faketcp"
UDP2RAW_CIPHER="none"
UDP2RAW_AUTH="md5"
UDP2RAW_KEY="random_key"

UDP2RAW_REMOTE=
UDP2RAW_LOCAL=
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
        '-r'|'--remote' )
            UDP2RAW_REMOTE="$2"
            shift 2
            ;;
        '-l'|'--local' )
            UDP2RAW_LOCAL="$2"
            shift 2
            ;;
        '-c'|'--cipher' )
            UDP2RAW_CIPHER="$2"
            shift 2
            ;;
        '--mode' )
            UDP2RAW_MODE="$2"
            shift 2
            ;;
        '--key' )
            UDP2RAW_KEY="$2"
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
mkdir -p $INST_DIR/$UDP2RAW_DIR
cd $INST_DIR/$UDP2RAW_DIR
wget -c $UDP2RAW_URL

if [ "x$UDP2RAW_REMOTE" == "x" ];then
    echo "argument [target], [remote] muste be specify"
    exit 1
fi

if [ "x$UDP2RAW_LOCAL" == "x" ];then
    echo "argument [local] muste be specify"
    exit 1
fi

if [ "$INST_MODE" == "server" ];then
tar -xvf `basename $UDP2RAW_URL` $UDP2RAW_CLIENT

# server logrun
cat > logrun.sh << EOF
#!/bin/bash
cd \`dirname \$0\`
eval \$(ps -ef | grep "[0-9] ./$UDP2RAW_SERVER" | awk '{print "kill "\$2}')
ulimit -n 512000
nohup ./$UDP2RAW_SERVER -s --auto-rule --cipher-mode $UDP2RAW_CIPHER --key $UDP2RAW_KEY -r "$UDP2RAW_REMOTE" -l "$UDP2RAW_LOCAL" --raw-mode $UDP2RAW_MODE >> udp2raw-$INST_MODE.log 2>&1 &
EOF

else [ "$INST_MODE" == "client" ]
tar -xvf `basename $UDP2RAW_URL` $UDP2RAW_SERVER

# client logrun
cat > logrun.sh << EOF
#!/bin/bash
cd \`dirname \$0\

eval \$(ps -ef | grep "[0-9] ./$UDP2RAW_CLIENT" | awk '{print "kill "\$2}')
ulimit -n 512000
nohup ./$UDP2RAW_CLIENT -c --auto-rule --cipher-mode $UDP2RAW_CIPHER --key $UDP2RAW_KEY -r "$UDP2RAW_REMOTE" -l "$UDP2RAW_LOCAL" --raw-mode $UDP2RAW_MODE >> udp2raw-$INST_MODE.log 2>&1 &
EOF
fi
chmod +x logrun.sh

echo Installation done!
