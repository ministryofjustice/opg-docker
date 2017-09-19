FROM registry.service.opg.digital/opguk/base

RUN wget -q \
        -O /tmp/go.tgz \
        https://storage.googleapis.com/golang/go1.9.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf /tmp/go.tgz \
    && rm /tmp/go.tgz \
    && GOPATH=/root/go /usr/local/go/bin/go get github.com/Instamojo/rdstail \
    && cp /root/go/bin/rdstail /usr/bin \
    && rm -rf /root/go

ADD docker/ /

ENV OPG_SERVICE rdstail
