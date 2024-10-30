FROM alpine:3.12

ARG JMETER_VERSION="5.6"
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_CUSTOM_PLUGINS_FOLDER=/plugins
ENV	JMETER_BIN=${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL=https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

ARG TZ="America/Sao_Paulo"
ENV TZ=${TZ}
RUN    apk update \
	&& apk upgrade \
	&& apk add openssl \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk8-jre tzdata curl unzip bash \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies \
	&& echo "prometheus.ip=0.0.0.0" >> /opt/apache-jmeter-5.6/bin/jmeter.properties \
	&& echo "prometheus.delay=120" >> /opt/apache-jmeter-5.6/bin/jmeter.properties 

ENV PATH=$PATH:$JMETER_BIN

COPY entrypoint.sh /
COPY minioupload.sh ${JMETER_HOME}

COPY /plugins/* ${JMETER_HOME}/lib/ext

WORKDIR	${JMETER_HOME}

ENTRYPOINT ["/entrypoint.sh"]