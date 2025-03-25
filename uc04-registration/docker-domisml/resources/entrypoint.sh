#!/bin/bash
set -e

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-changeme}
DB_USER_PASSWORD=${DB_USER_PASSWORD:-changeme}
MYSQL_DATA_DIR=${DATA_DIR}/mysql
DOMISML_DATA_DIR=${DATA_DIR}/domisml
DOMISML_INIT_DIR=${DATA_DIR}/init
DOMISML_INIT_DB_DIR=${DOMISML_INIT_DIR}/database-scripts

initialize(){
  cd ${DOMISML_HOME}

  if [ ! -d "${DOMISML_DATA_DIR}/logs" ]; then
    echo "[DEBUG] Create log folder: [${DOMISML_DATA_DIR}]/logs"
    mkdir -p ${DOMISML_DATA_DIR}/logs
  fi
  rm -rf ${DOMISML_HOME}/logs
  ln -sf ${DOMISML_DATA_DIR}/logs ${DOMISML_HOME}/logs


  if [ ! -d "${DOMISML_DATA_DIR}/config" ]; then
    echo "[DEBUG] Create config folder: [${DOMISML_DATA_DIR}]/config"
    mkdir -p ${DOMISML_DATA_DIR}/config
  fi
  chown -R sml:sml "${DOMISML_DATA_DIR}/logs"
  chown -R sml:sml "${DOMISML_DATA_DIR}/config"

  if [ -f ".initialized" ]; then
      echo "[INFO] Container already initialized!"
      return;
  fi

  init_mysql
  init_domisml
  touch ".initialized"
}

prepareIniDatabaseData() {
  echo "[INFO] Prepare database for DomiSML"
  if [  -d "${DOMISML_INIT_DB_DIR}" ]; then
    echo "[INFO] database script folder: [${DOMISML_INIT_DB_DIR}] already exists!"
    return;
  fi
  CONFIGURATION_FOLDER=${CONFIGURATION_FOLDER:-"${DOMISML_DATA_DIR}/config"}
  DNS_HOSTNAME=${DNS_HOSTNAME:-"localhost"}
  DNS_ENABLED=${DNS_ENABLED:-"false"}
  DNS_DOMAIN=${DNS_DOMAIN:-"ecosystem"}
  DNS_ZONE=${DNS_ZONE:-"ecosystem.local"}
  IDENTIFIER_DNS_TEMPLATE=${IDENTIFIER_DNS_TEMPLATE:-""}
  PARTICIPANT_ID_REGEXP=${PARTICIPANT_ID_REGEXP:-"^.*$"}
  mkdir -p ${DOMISML_INIT_DB_DIR}
  echo "[INFO] Create data script from template"
  eval "echo \"$(cat ${DOMISML_HOME}/init/database-scripts/template-data.sql)\"" > ${DOMISML_INIT_DB_DIR}/02-init-data.sql
}

init_mysql() {
  # start MYSQL
  echo  "[INFO]  Initialize mysql service."
  #service mysql start
  # reinitialize mysql to start it with enabled lowercase tables, 'root' password and change the data folder
   echo  "[DEBUG] Set mysql data on volume folder: [${MYSQL_DATA_DIR}]."
  service mysql stop
  rm -rf /var/lib/mysql
  if [ ! -d ${MYSQL_DATA_DIR} ]; then
    mkdir -p ${MYSQL_DATA_DIR}
  fi
  ln -sf ${MYSQL_DATA_DIR} /var/lib/mysql
  chmod -R 0775 ${MYSQL_DATA_DIR}
  usermod -d ${MYSQL_DATA_DIR} mysql
  chown mysql:mysql ${MYSQL_DATA_DIR}

  echo  "[INFO] Initialize mysql folder."
  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" > /tmp/mysql-init
  mysqld --defaults-file=/etc/mysql/my.cnf --initialize --lower_case_table_names=1 --init-file=/tmp/mysql-init --user=mysql --console
  service mysql start
  echo  "[INFO] Startup mysql service."
  PID_MYSQL=$(cat /var/run/mysqld/mysqld.sock.lock);
  if  [ ! -d ${MYSQL_DATA_DIR}/${DB_SCHEMA} ]; then
    echo  "[INFO] Initialize: [$DB_SCHEMA] for [$DB_USER]."
    # create database
    mysql -h localhost -u root --password=${MYSQL_ROOT_PASSWORD} -e "drop schema if exists $DB_SCHEMA;DROP USER IF EXISTS $DB_USER;  create schema $DB_SCHEMA;alter database     $DB_SCHEMA charset=utf8; create user $DB_USER identified by '$DB_USER_PASSWORD';grant all on $DB_SCHEMA.* to $DB_USER;"
    mysql -h localhost -u root --password=${MYSQL_ROOT_PASSWORD} $DB_SCHEMA  < ${DOMISML_HOME}/init/database-scripts/mysql5innodb.ddl
    prepareIniDatabaseData

    for filepath in ${DOMISML_INIT_DB_DIR}/*; do
      [[ ! -f "${filepath}" ]] && continue
      echo  "[INFO] Execute script [${filepath}] for scheme: [$DB_SCHEMA]."
      mysql -h localhost -u root --password=${MYSQL_ROOT_PASSWORD} $DB_SCHEMA < ${filepath}
    done;
  fi
}

init_domisml() {
  echo "[INFO] init domisml configuration: ${DOMISML_HOME}/application.properties"
  {
    echo "# DomiSML application configuration"
    echo "server.port=8080"
    echo "# Database configuration"
    echo "sml.hibernate.dialect=org.hibernate.dialect.MySQLDialect"
    echo "sml.jdbc.driver=com.mysql.cj.jdbc.Driver"
    echo "sml.jdbc.url=jdbc:mysql://localhost:3306/$DB_SCHEMA?allowPublicKeyRetrieval=true"
    echo "sml.jdbc.user=$DB_USER"
    echo "sml.jdbc.password=$DB_USER_PASSWORD"
  } >>  ${DOMISML_HOME}/application.properties

  mkdir -p ${DOMISML_HOME}/classes
  {
    echo "# DomiSML application configuration"
  } >>  ${DOMISML_HOME}/classes/sml.config.properties

  cp ${DOMISML_HOME}/init/encriptionPrivateKey.private ${DOMISML_DATA_DIR}/config
  cp ${DOMISML_HOME}/init/keystore.p12 ${DOMISML_DATA_DIR}/config
  cp ${DOMISML_HOME}/init/truststore.p12 ${DOMISML_DATA_DIR}/config

  # override init artefacts as keystore, truststore, keys, ...
  if [  -d /opt/smlconf/init-configuration ]; then
     cp -r /opt/smlconf/init-configuration/*.* ${DOMISML_DATA_DIR}/config
  fi

}

initialize;

#----------------------------------------------------
# start DomiSML
echo  "[INFO]  Start DomiSML"
cd ${DOMISML_HOME}
ls -ltr
#su -s /bin/sh sml -c "${JAVA_HOME}/bin/java -cp ${DOMISML_HOME}/classes:domisml-springboot-exec.jar org.springframework.boot.loader.JarLauncher"
su - -s /bin/sh sml -c "${JAVA_HOME}/bin/java -jar domisml-springboot-exec.jar"


