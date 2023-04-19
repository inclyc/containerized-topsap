FROM debian:buster-slim AS extractor

ARG TOPSAP_URL

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    busybox perl

RUN busybox wget ${TOPSAP_URL} -O topsap.deb && \
    dpkg -x topsap.deb source && \
    rm topsap.deb && \
    mkdir topsap-extract && \
    sh source/opt/TopSAP/TopSAP*.bin --target topsap-extract --noexec && \
    rm -rf source && \
    cp topsap-extract/common/sv_websrv /usr/local/bin/sv_websrv && \
    cp topsap-extract/common/libvpn_client.so /usr/local/lib/libvpn_client.so && \
    cp topsap-extract/common/topvpn /usr/local/bin/topvpn && \
    perl -0777 -pe 's/.\/libvpn_client\.so/substr q{libvpn_client.so}."\0"x length$&,0,length$&/e or die "pattern not found"' -i /usr/local/bin/sv_websrv && \
    rm -rf topsap-extract

FROM debian:buster-slim

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    dante-server expect iproute2

RUN groupadd -r socks && useradd -r -g socks socks

COPY --from=extractor /usr/local/ /usr/local
COPY rootfs /

VOLUME [ "/data" ]

ENTRYPOINT [ "entrypoint" ]
