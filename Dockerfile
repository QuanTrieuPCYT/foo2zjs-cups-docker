FROM debian:bookworm-slim

ARG S6_OVERLAY_VERSION=3.2.1.0

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp

RUN apt-get update
RUN apt-get dist-upgrade --no-install-recommends -qqy
RUN apt-get install cups avahi-daemon vim make xz-utils --no-install-recommends -qqy
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz
RUN rm -Rf /tmp/s6-overlay-noarch.tar.xz /tmp/s6-overlay-x86_64.tar.xz /tmp/s6-overlay-symlinks-noarch.tar.xz /tmp/s6-overlay-symlinks-arch.tar.xz

COPY foo2zjs.tar.gz .
RUN tar xf foo2zjs.tar.gz
WORKDIR foo2zjs
RUN make install
RUN make install-hotplug
RUN make cups
WORKDIR /
RUN rm -R foo2zjs foo2zjs.tar.gz

RUN apt-get purge vim make xz-utils --autoremove -qqy
RUN apt-get autoclean -y && apt-get clean -qqy
RUN rm -rf /var/lib/apt/lists/*

RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf
RUN cp -rp /etc/cups /etc/cups-bak
COPY ./services /etc/services.d
COPY ./cont-init /etc/cont-init.d

CMD ["/init"]
