The DomiSML spring-boot docker image and mysql database.
================================

This DomiSML (Spring-Boot) Docker image includes DomiSML v4.3.1, built as the Spring Boot artifact, with a MySQL database integrated within the container. This image is strictly designed for testing and demonstration purposes only. It does not support secure deployment features such as TSIG or SIG(0) DNSSEC for DNS integration, or HTTPS endpoints for SMP authentication.

To simplify testing, the image is preconfigured with an SSLClientCert header, which MUST always be utilized behind a reverse proxy.

# How to build

To build an image with docker compose command:

    docker compose build

Then build image with command:

    docker build -t domisml:4.3.1 .

or with the filepath to the Dockerfile if is build from any other directory:

    # build with docker compose
    docker compose -f uc04-registration/docker-domisml/docker-compose.yml build
    # the docker build variant
    docker build -t domisml:4.3.1 -f uc04-registration/docker-domisml/Dockerfile uc04-registration/docker-domisml/


# How to run

Tu run image execute command:

    docker run --name domisml -p 8084:8080 -p 3304:3306 domisml:4.3.1

In your browser, enter `http://localhost:8084/edelivery-sml` .

## Configuration options at startup

Purpose of this docker image is to provide a quick way to start the DomiSML application with a simple DNS integration. The following environment variables can be set at startup:
 
- `DNS_ENABLED` - Enable DNS integration. Default value is `false`.
- `DNS_HOSTNAME` - The hostname of the DomiSML application. Default value is `localhost`.
- `DNS_DOMAIN` - The name of the ecosystem. Default value is `ecosystem`.
- `DNS_ZONE` - The version of the ecosystem. Default value is `1.0`.
- `PARTICIPANT_ID_REGEXP` - The regular expression for validation of participant identifier. Default value is any identifier: `^.*$`.
- `MYSQL_ROOT_PASSWORD` - The password for the root user of the MySQL database. Default value is `changeme`.
- `DB_USER` - The DomiSML database user. Default value is `sml`.
- `DB_USER_PASSWORD` - The DomiSML database user password. Default value is `changeme`.
- `DB_SCHEMA` - The DomiSML database scheme. Default value is `domisml`.



## Useful commands

To connect to the mysql database use the following command:

    docker exec -it container name mysql -h localhost -u root --password=changeme domisml
