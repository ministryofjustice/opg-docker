FROM registry.service.opg.digital/opguk/base

RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

ENV JAVA_MAJOR_VERSION=8
ENV JAVA_UPDATE_VERSION=77
ENV JAVA_BUILD_NUMER=03

# install java
ENV JAVA_VERSION=1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}
ENV JAVA_TARBALL=jre-${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-linux-x64.tar.gz
ENV JAVA_HOME=/opt/java/jre${JAVA_VERSION}
RUN wget --no-check-certificate --directory-prefix=/tmp \
         --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
         http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-b${JAVA_BUILD_NUMER}/${JAVA_TARBALL} && \
    mkdir -p /opt/java && \
    tar -xzf /tmp/${JAVA_TARBALL} -C /opt/java/ && \
    rm -rf /tmp/* && rm -rf /var/log/* && \
    update-alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 100 && \
    update-alternatives --install /usr/bin/javaws javaws ${JAVA_HOME}/bin/javaws 100 && \
    update-alternatives --install /usr/bin/jcontrol jcontrol ${JAVA_HOME}/bin/jcontrol 100 && \
    update-alternatives --install /usr/bin/jexec jexec ${JAVA_HOME}/lib/jexec 100 && \
    update-alternatives --install /usr/bin/jexec jexec ${JAVA_HOME}/lib/jexec 100 --slave /usr/share/binfmts/jar jexec-binfmt ${JAVA_HOME}/bin/javaws

ENV OPG_SERVICE jre-8
