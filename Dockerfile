FROM golang:alpine as builder

RUN apk add --update bash git make build-base npm && \
    rm -rf /var/cache/apk/* && \
    cd /src/AdGuardHome && \
    git clone https://github.com/Bitsonwheels/heroku-adguard.git

WORKDIR /src/AdGuardHome
COPY . /src/AdGuardHome
RUN make -j 1

FROM alpine:latest
LABEL maintainer="AdGuard Team <devteam@adguard.com>"

# Update CA certs
RUN apk --no-cache --update add ca-certificates && \
    rm -rf /var/cache/apk/* && mkdir -p /opt/adguardhome
RUN apk install setcap

COPY --from=build /src/AdGuardHome/AdGuardHome /opt/adguardhome/AdGuardHome

EXPOSE 80/tcp 443/tcp 853/tcp 853/udp 3000/tcp

VOLUME ["/opt/adguardhome/conf", "/opt/adguardhome/work"]

ENTRYPOINT ["/opt/adguardhome/AdGuardHome"]
CMD ["-h", "0.0.0.0", "-c", "/opt/adguardhome/conf/AdGuardHome.yaml", "-w", "/opt/adguardhome/work"]
