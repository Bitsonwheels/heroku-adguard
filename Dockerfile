FROM golang:alpine AS build
RUN adduser -D bits
USER bits

RUN apk add --update bash git make build-base npm vim mc go && \
    rm -rf /var/cache/apk/*
    
# install cap package and set the capabilities on busybox
RUN apk add --update --no-cache libcap && \
    setcap cap_setgid=ep /bin/AdGuardHome && \
    setcap 'CAP_NET_BIND_SERVICE=+eip CAP_NET_RAW=+eip' ./AdGuardHome && \
    setcap 'CAP_NET_BIND_SERVICE=+eip CAP_NET_RAW=+eip' ./bin/AdGuardHome

WORKDIR ./app/AdGuardHome
COPY . ./app/AdGuardHome
RUN git clone https://github.com/Bitsonwheels/heroku-adguard.git && \
    cd heroku-adguard
RUN make
RUN wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz  && \
    tar -C /usr/local -xzf go1.10.3.linux-amd64.tar.gz  && \
    export PATH=$PATH:/usr/local/go/bin
    
# Update CA certs
RUN apk --no-cache --update add ca-certificates && \
    rm -rf /var/cache/apk/* && mkdir -p /opt/adguardhome
RUN wget https://github.com/Bitsonwheels/heroku-adguard/archive/refs/heads/master.zip
RUN unzip  master.zip -d /app//AdGuardHome
COPY --from=build /app/AdGuardHome/AdGuardHome /app/AdGuardHome/AdGuardHome

RUN apk add libcap go unzip && \
mkdir /app/AdGuardHome
RUN wget https://github.com/Bitsonwheels/heroku-adguard/archive/refs/heads/master.zip
RUN unzip master.zip -d /app/adguardhome/AdGuardHome && \
cd /app/AdGuardHome/bin && \
./AdGuardHome -s install
RUN setcap 'CAP_NET_BIND_SERVICE=+eip CAP_NET_RAW=+eip' ./bin/AdGuardHome
ENV LISTEN_PORT 8080
EXPOSE 8080/tcp 1443/tcp 1853/tcp 1853/udp 3000/tcp

RUN mkdir /app/AdGuardHome && \
    mkdir /app/AdGuardHome\conf && \
wget https://raw.githubusercontent.com/Bitsonwheels/heroku-adguard/master/AdGuardHome.yaml -O AdGuardHome.yaml
RUN ./bin/AdGuardHome -s install
VOLUME ["/app/AdGuardHome/conf", "/app/AdGuardHome/work"]    
ENTRYPOINT ["/app/AdGuardHome"]
CMD ["-h", "0.0.0.0", "-c", ":/AdGuardHome.yaml", "-w", "/app/adguardhome/work"]
