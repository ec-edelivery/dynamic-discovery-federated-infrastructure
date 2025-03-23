FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="Joze RIHTARSIC"
LABEL org.opencontainers.image.source="https://github.com/ec-edelivery/dynamic-discovery-federated-infrastructure"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.title="DomiSMP"
LABEL org.opencontainers.image.description="DomiSMP is a sample software component that provides a set of services for the management of Service Metadata Publisher (SMP) instances locations in the dns. "
LABEL org.opencontainers.image.licenses="EUPL-1.2"

ENV DATA_DIR=/data  \
    DOMISML_VERSION=4.3.1 \
    DOMISML_SHA512=5e73b4b1f825fd75c7d60a7f7e648b9c0ed0037e1f8ec5686ca0bd65f032e54f5a5ed1da5ae86256ddbf2ca063def3e9225175718d575bf93a53737a65fd513f \
    DOMISML_SETUP_SHA512=464f5fb2b033105d7d6c4eec01d09f3aaeb660eb506874cb7f6a4bf87ab50e143609d60a5021c58be6e5336fe63bf8f9ba0429939aa898f3ff0187c7f9822bb6 \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/ \
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
        openjdk-11-jdk \
	    unzip \
        wget \
        curl \
        vim \
        haveged && \
   rm -rf /var/lib/apt/lists/* && \
    # create bdmsl user
    mkdir -p "${DOMISML_HOME}" && \
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
