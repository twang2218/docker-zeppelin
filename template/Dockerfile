# As the integrated `node` binary are dynamically linked to /lib64/, it cannot use Alpine image
FROM openjdk:8-jdk-slim

# Alpine
# RUN apk --no-cache add bash
RUN set -xe \
  && apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/list/*

ENV ZEPPELIN_VERSION 0.7.2
ENV ZEPPELIN_HOME /opt/zeppelin

ENV ZEPPELIN_LOG_DIR /data/log
ENV ZEPPELIN_PID_DIR /data/run
ENV ZEPPELIN_NOTEBOOK_DIR /data/notebook
VOLUME /data

ENV PATH=$PATH:${ZEPPELIN_HOME}/bin
EXPOSE 8080

RUN set -xe \
  && cd tmp \
  && wget http://www.apache.org/dist/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-netinst.tgz \
  && tar -zxvf zeppelin-${ZEPPELIN_VERSION}-bin-netinst.tgz \
  && rm *.tgz \
  && mkdir -p `dirname ${ZEPPELIN_HOME}` \
  && mv zeppelin-${ZEPPELIN_VERSION}-bin-netinst ${ZEPPELIN_HOME}

WORKDIR ${ZEPPELIN_HOME}

# We don't need that much memory for interpreter installation
RUN set -xe \
  && export ZEPPELIN_MEM='-Xmx256m' \
  && ./bin/install-interpreter.sh --list #INTERPRETER#

CMD ["zeppelin.sh"]
