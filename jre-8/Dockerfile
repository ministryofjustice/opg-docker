FROM registry.service.dsd.io/opguk/base:latest

RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:openjdk-r/ppa -y

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_VERSION 8u45
ENV JAVA_UBUNTU_VERSION 8u45-b14-1~14.04
ENV CA_CERTIFICATES_JAVA_VERSION 20130815ubuntu1

RUN set -x \
  && apt-get update \
  && apt-get install -y \
    openjdk-8-jre-headless="$JAVA_UBUNTU_VERSION" \
    ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
  && rm -rf /var/lib/apt/lists/*

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

ENV OPG_SERVICE jre-8
