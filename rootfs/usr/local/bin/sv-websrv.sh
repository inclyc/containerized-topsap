#!/usr/bin/env sh
cd /data
ln -s /topsap/libvpn_client.so .
trap "rm -f ./libvpn_client.so" EXIT
/topsap/sv_websrv
