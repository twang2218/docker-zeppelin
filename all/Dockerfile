# As the integrated `node` binary inside 'zeppelin' are dynamically linked to /lib64/, it cannot use Alpine image for now
FROM openjdk:8-jdk-slim

ENV ZEPPELIN_HOME /opt/zeppelin
ENV PATH=$PATH:${ZEPPELIN_HOME}/bin

# 8080 is for zeppelin web UI
EXPOSE 8080
# 4040 is for spark UI
EXPOSE 4040

RUN groupadd -r --gid 501 zeppelin \
  && useradd -r --uid 501 --home-dir ${ZEPPELIN_HOME} --create-home -g zeppelin zeppelin

WORKDIR ${ZEPPELIN_HOME}

# Install wget for later zeppelin installation
RUN set -xe \
  && apt-get update \
  && apt-get install -y wget \
  && sleep 1 \
  && rm -rf /var/lib/apt/list/*

ENV ZEPPELIN_DATA /data
ENV ZEPPELIN_LOG_DIR ${ZEPPELIN_DATA}/log
ENV ZEPPELIN_PID_DIR ${ZEPPELIN_DATA}/run
ENV ZEPPELIN_NOTEBOOK_DIR ${ZEPPELIN_DATA}/notebook

# Prepare the permission for the mount points
RUN mkdir -p ${ZEPPELIN_DATA} && chown zeppelin:zeppelin ${ZEPPELIN_DATA}
VOLUME ${ZEPPELIN_DATA}

# Let temporary directories to be volumes as well
VOLUME /tmp

USER zeppelin

ENV ZEPPELIN_VERSION 0.7.2

RUN set -xe \
  && cd /tmp \
  && wget http://www.apache.org/dist/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-netinst.tgz \
  && tar -zxvf zeppelin-${ZEPPELIN_VERSION}-bin-netinst.tgz -C ${ZEPPELIN_HOME} --strip-components=1 \
  && rm *.tgz

# Install interpreter dependencies (R, Python)
USER root
RUN set -xe \
  && apt-get update \
  && apt-get install -y python python-pip python-matplotlib python-matplotlib-data r-base r-base-dev r-recommended r-cran-knitr r-cran-caret r-cran-data.table r-cran-glmnet \
  && chmod a+wx /usr/local/lib/R/site-library || true \
  && sleep 1 \
  && rm -rf /var/lib/apt/list/*
USER zeppelin

# We don't need that much memory for interpreter installation
RUN set -xe \
  && mkdir -p ${ZEPPELIN_LOG_DIR} \
  && export ZEPPELIN_MEM='-Xmx256m' \
  && install-interpreter.sh --list && install-interpreter.sh --all

CMD ["zeppelin.sh"]
