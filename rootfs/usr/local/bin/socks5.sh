#!/usr/bin/env bash

# https://github.com/Hagb/docker-easyconnect/blob/8a1dd3b5644716dd9f664b23fa1bab2e4fcb3555/docker-root/usr/local/bin/start.sh#L34

cp /etc/danted.conf.sample /run/danted.conf

if [[ -n "$SOCKS_PASSWD" && -n "$SOCKS_USER" ]];then
	id $SOCKS_USER &> /dev/null
	if [ $? -ne 0 ]; then
		useradd $SOCKS_USER
	fi

	echo $SOCKS_USER:$SOCKS_PASSWD | chpasswd
	sed -i 's/socksmethod: none/socksmethod: username/g' /run/danted.conf

	echo "use socks5 auth: $SOCKS_USER:$SOCKS_PASSWD"
fi

internals=""
externals=""
for iface in $(ip -o addr | sed -E 's/^[0-9]+: ([^ ]+) .*/\1/' | sort | uniq | grep -v "lo\|sit\|vir"); do
        internals="${internals}internal: $iface port = 1080\\n"
        externals="${externals}external: $iface\\n"
done
sed /^internal:/c"$internals" -i /run/danted.conf
sed /^external:/a"$externals" -i /run/danted.conf
# 在虚拟网络设备 tun0 打开时运行 danted 代理服务器
[ -n "$NODANTED" ] || (while true
do
sleep 3
[ -d /sys/class/net/tun0 ] && {
	chmod a+w /tmp
	/usr/sbin/danted -f /run/danted.conf
}
done
)&

