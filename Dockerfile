FROM golang:alpine as builder

RUN apk add --update bash git make go build-base npm && \
    rm -rf /var/cache/apk/*

# Configure Go
#ENV GOROOT /usr/lib/go
#ENV GOPATH /go
#ENV PATH /go/bin:$PATH
#RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin
# Install Glide
#RUN go get -u github.com/Masterminds/glide/...
#WORKDIR $GOPATH
#CMD ["make"]

WORKDIR ./AdGuardHome
COPY . ./AdGuardHome
RUN git clone https://github.com/Bitsonwheels/heroku-adguard.git && \
    cd heroku-adguard  && \
    wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz  && \
    tar -C /usr/local -xzf go1.10.3.linux-amd64.tar.gz  && \
    export PATH=$PATH:/usr/local/go/bin
RUN apk add libcap go
RUN wget https://github.com/Bitsonwheels/heroku-adguard/archive/refs/heads/master.zip
RUN unzip master.zip -d /opt/adguardhome/AdGuardHome && \
cd /opt/adguardhome/AdGuardHome
RUN make

FROM alpine:latest
LABEL maintainer="AdGuard Team <devteam@adguard.com>"

# Update CA certs
RUN apk --no-cache --update add ca-certificates && \
    rm -rf /var/cache/apk/* && mkdir -p /opt/adguardhome
#RUN apk install setcap go
#RUN wget https://github.com/Bitsonwheels/heroku-adguard/archive/refs/heads/master.zip
#RUN unzip  master.zip -d /opt/adguardhome/AdGuardHome
COPY --from=build /src/AdGuardHome/AdGuardHome /opt/adguardhome/AdGuardHome

EXPOSE 80/tcp 443/tcp 853/tcp 853/udp 3000/tcp

VOLUME ["/opt/adguardhome/conf", "/opt/adguardhome/work"]

ENTRYPOINT ["/opt/adguardhome/AdGuardHome"]
CMD ["-h", "0.0.0.0", "-c", "/opt/adguardhome/conf/AdGuardHome.yaml", "-w", "/opt/adguardhome/work"]
