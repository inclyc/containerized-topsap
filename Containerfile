FROM debian:buster-slim AS extractor

ARG TOPSAP_URL

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    busybox

RUN busybox wget ${TOPSAP_URL} -O topsap.deb && \
    dpkg -x topsap.deb source && \
    rm topsap.deb && \
    mkdir topsap-extract && \
    sh source/opt/TopSAP/TopSAP*.bin --target topsap-extract --noexec && \
    rm -rf source && \
    mkdir topsap && \
    cp topsap-extract/common/sv_websrv topsap && \
    cp topsap-extract/common/libvpn_client.so topsap && \
    cp topsap-extract/common/topvpn topsap && \
    rm -rf topsap-extract

FROM debian:buster-slim

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    dante-server expect iproute2

RUN groupadd -r socks && useradd -r -g socks socks

COPY --from=extractor /topsap /topsap
COPY rootfs /

VOLUME [ "/data" ]

ENTRYPOINT [ "entrypoint" ]
