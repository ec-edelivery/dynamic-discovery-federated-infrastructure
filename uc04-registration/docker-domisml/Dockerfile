FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="Joze RIHTARSIC"
LABEL org.opencontainers.image.source="https://github.com/ec-edelivery/dynamic-discovery-federated-infrastructure"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.title="DomiSMP"
LABEL org.opencontainers.image.description="DomiSMP is a sample software component that provides a set of services for the management of Service Metadata Publisher (SMP) instances locations in the dns. "
LABEL org.opencontainers.image.licenses="EUPL-1.2"

ENV DATA_DIR=/data  \
    DOMISML_VERSION=5.0.RC1 \
    DOMISML_SHA512=c2c088c2a21aa9c0e04a142552c6e00fb9fe57b1b966242db09a9b142031900d10eea0b920634661ed674f7a7ad371ca0e7d695a868482cde8726f2ab8748fc4 \
    DOMISML_SETUP_SHA512=1abc63aa4b224bb018282025463a5085a7e1164daaf6766c3695d21573bfe8ae625b3811bb1bdf18fd7a11c9f603314510ed669098bf8a1fef8cf1d16e59e120 \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64/ \
    DOMISML_HOME=/opt/domisml \
    DB_SCHEMA=domisml \
    DB_USER=sml

EXPOSE 3306 8080
VOLUME ${DATA_DIR}

RUN apt-get update && \
# get utils, bind9, java, mysql
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bind9utils  \
        dnsutils \
        mysql-server \
        openjdk-21-jdk \
	    unzip \
        wget \
        curl \
        vim \
        haveged && \
   rm -rf /var/lib/apt/lists/*
    # create bdmsl user
RUN    mkdir -p "${DOMISML_HOME}" && \
    mkdir -p "${DOMISML_HOME}/config" && \
    mkdir -p "${DOMISML_HOME}/logs" && \
    mkdir -p "${DOMISML_HOME}/init" && \
    mkdir -p "${DATA_DIR}" && \
    groupadd -g 1001 sml && \
    useradd -s /bin/bash -u 1001 -g sml -d ${DOMISML_HOME} sml && \
    usermod -a -G mysql sml && \
    chown -R sml:sml ${DOMISML_HOME} && \
    chown -R sml:sml ${DATA_DIR} && \
    # install
    wget -O ${DOMISML_HOME}/domisml-springboot-exec.jar "https://ec.europa.eu/digital-building-blocks/artifact/repository/eDelivery/eu/europa/ec/bdmsl/bdmsl-springboot/${DOMISML_VERSION}/bdmsl-springboot-${DOMISML_VERSION}-exec.jar" && \
    sha512sum ${DOMISML_HOME}/domisml-springboot-exec.jar | grep $DOMISML_SHA512 && \
    # get database ddl scripts
    wget -O /tmp/domisml-setup.zip "https://ec.europa.eu/digital-building-blocks/artifact/repository/eDelivery/eu/europa/ec/bdmsl/bdmsl-webapp/${DOMISML_VERSION}/bdmsl-webapp-${DOMISML_VERSION}-setup.zip" && \
    sha512sum /tmp/domisml-setup.zip | grep $DOMISML_SETUP_SHA512 && \
    cd /tmp && \
    jar -xf /tmp/domisml-setup.zip && \
    mv  bdmsl-webapp-*/*.* ${DOMISML_HOME}/init/ && \
    mv  bdmsl-webapp-*/database-scripts ${DOMISML_HOME}/init && \
    rm -rf bdmsl-webapp-*/ && \
    # configure  mysql
    echo "[mysqld]" >> /etc/mysql/my.cnf  && \
    echo "lower_case_table_names=1" >> /etc/mysql/my.cnf  && \
    echo "collation-server=utf8_unicode_ci" >> /etc/mysql/my.cnf  && \
    echo "init-connect='SET NAMES utf8'" >> /etc/mysql/my.cnf  && \
    echo "character-set-server=utf8" >> /etc/mysql/my.cnf && \
    echo "default_authentication_plugin=mysql_native_password" >> /etc/mysql/my.cnf  && \
    sed -i -e "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf

# deploy application
COPY resources/entrypoint.sh /sbin/entrypoint.sh
COPY resources/template-data.sql ${DOMISML_HOME}/init/database-scripts/

# set configuration
RUN  chmod 755 /sbin/entrypoint.sh

WORKDIR ${DOMISML_HOME}

ENTRYPOINT ["/sbin/entrypoint.sh"]
