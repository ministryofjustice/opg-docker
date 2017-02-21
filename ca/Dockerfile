FROM registry.service.opg.digital/opguk/base

RUN wget -qO /usr/local/sbin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 \
    && chmod +x  /usr/local/sbin/cfssl \
    && sha256sum /usr/local/sbin/cfssl | awk '$1!="eb34ab2179e0b67c29fd55f52422a94fe751527b06a403a79325fed7cf0145bd" {exit 1}'

RUN wget -qO /usr/local/sbin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 \
    && chmod +x  /usr/local/sbin/cfssljson \
    && sha256sum /usr/local/sbin/cfssljson | awk '$1!="1c9e628c3b86c3f2f8af56415d474c9ed4c8f9246630bd21c3418dbe5bf6401e" {exit 1}'

RUN mkdir -p /data/cfssl


ADD  docker/confd /etc/confd


ENV OPG_CA_CLIENT_API_KEY 123456
ENV OPG_CA_SERVER_API_KEY 987654
