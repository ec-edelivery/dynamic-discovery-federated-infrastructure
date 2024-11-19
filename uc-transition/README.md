# Transition of the incubator domain


NOTE: This document is currently a work in progress and subject to changes.

## Introduction

To promote and facilitate electronic message exchange and reduce the costs of establishing various messaging networks (also known as ecosystems), the European Commission’s eDelivery building blocks and services act as incubators for new message exchange networks. eDelivery strives to balance lowering the costs of establishing new networks with fostering sustainability and market growth for various software and service providers.

As new networks are established, the demand for services and software in the market is growing. At the same time the eDelivery profiles, which are based only on open standards, along with sample implementations published under OpenSource licenses and conformance tests, aim to assist software and service providers in reducing development costs. This aims to helps them to achieve market maturity more quickly and cost-effectively.

Therefore, the aim of the eDelivery building block components and services is to offer various configuration options for networks to find the best setup and new features. However, once a network reaches maturity, it is required to transition to more user-friendly, high-performance software solutions and services with quality support from the market.

The provided use cases aim to demonstrate the transition from the current eDelivery “incubator” DNS domain to a new federated DNS service with a partitioned DNS domain, as described in the [README.md](../README.md). Because the “incubator” eDelivery SML service is currently used in production (and will likely be the case for any new network ecosystem as well), the transition to the new DNS domain must allow gradual transition. This PoC  ensures that existing services remain unaffected during the transition and makes the shift from "incubator" to "ecosystem SML service" more robust, and more seamless.


Additionally, the use cases below illustrates how the existing Docker environment 
described in the [README.md](../README.md) can be extended to support various test scenarios.



### The incubator domain

The current eDelivery hosts the  "incubator" SML service on the domain: `edelivery.tech.ec.europa.eu` and
the acceptance DNS domain: `acc.edelivery.tech.ec.europa.eu`. 

The domain is flat, that is having all records on the same domain level as example 

    IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    IDUC2ABCE.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    IDUC3ABCF.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    IDUC4ABCG.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    ...

Note: in the real case example the fist part of the domain is a hash over the participant identifier.

    <DNS-QUERY> ::= <hash-over-(part-of?)identifier> "." [<scheme> "."] <top-level-domain>


Where in the example above:

- **hash-over-(part-of?)identifier**: is for example  ‘IDUC1ABCD’ (how the hash is calculated is out of scope in the initial  PoC stage, but it will be important part of the future steps)
- **scheme**: ‘iso6523-actorid-upis’
- **top-level-domain**: is ‘edelivery.tech.ec.europa.eu’


## Use cases

The PoC assumes flat "incubator" domain and the new federated domain with partitioned DNS domain usi. 

The domain is "flat", that is having all records on the same top DNS domain as example

    IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    IDUC2ABCE.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    IDUC3ABCF.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    IDUC4ABCG.iso6523-actorid-upis.edelivery.tech.ec.europa.eu

The incubator environment is added as new service to the Docker environment as described in the [README.md](../README.md).
and the environment is extended to support various test scenarios.


### Use case 1: Extend environment with the incubator DNS service to the environment 

This use case aims to evaluate the extensibility of the Docker Compose environment 
with DNS services, rather than testing the functions of a federated DNS itself. It 
introduces the incubator service to the existing environment. This approach is 
designed to be generic and can also be applied to integrate other services, such as 
the SMP service, the AP service, etc.


The operational goal of the use case is to have additional DNS "edelivery.tech.ec.europa.eu" domain  
in the environment with the records as described above.

### Use case 2: Partial transition of the incubator domain to the federated DNS domain  

In this use case, the incubator domain is transitioned to the federated DNS domain. The owner of ecosystem 
network creates and partitioned subdomains as examples

    0088.iso6523.participants.ecosystem.org 
    0195.iso6523.participants.ecosystem.org
    9914.iso6523.participants.ecosystem.org
    9954.iso6523.participants.ecosystem.org
    0151.iso6523.participants.ecosystem.org

in this usecase the domains 0088, 0195, 9914, are already trandfered to the new ecosystem DNS servers 
but the 9954, and 0151 are still in the incubator domain. The ecosystem owner wants to redirect the 9954 to  still be resolved by the incubator DNS server.

In the example the following two records belongs to partition 9954  

    IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    IDUC2ABCE.iso6523-actorid-upis.edelivery.tech.ec.europa.eu

And the following two records belongs to partition 0151

    IDUC3ABCF.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    IDUC4ABCG.iso6523-actorid-upis.edelivery.tech.ec.europa.eu

After the configuring the ecosystem DNS servers the records should be resolved using the ecosystem top domain as.

    IDUC1ABCD.9954.iso6523.participants.ecosystem.org
    IDUC2ABCE.9954.iso6523.participants.ecosystem.org
    IDUC3ABCF.0151.iso6523.participants.ecosystem.org
    IDUC4ABCG.0151.iso6523.participants.ecosystem.org

### Use case 3: Migrate records for the domain 9954

In this use case, the ecosystem owner wants to migrate the records for the domain 9954 to the ecosystem DNS servers
and drops the redirection  9954.iso6523.participants.ecosystem.org to the incubator DNS server.

The records should be resolved using the ecosystem top domain as.

    IDUC1ABCD.9954.iso6523.participants.ecosystem.org
    IDUC2ABCE.9954.iso6523.participants.ecosystem.org

## Environment Setup

The PoC environment is made to extend the existing Docker Compose environment with the incubator DNS zone
"edelivery.tech.ec.europa.eu".

The incubator DNS service is added to the Docker environment using the Docker Compose’s
“include ” feature. For more details, refer to the  [Docker compose 'Include' feature](https://docs.docker.com/compose/how-tos/multiple-compose-files/include/).

The following example demonstrates how the incubator DNS service is added to the Docker environment:

    include:
    - ../docker-compose.yml  #the initial environment

    services: 
      incubator-domain:
       image: internetsystemsconsortium/bind9:9.18
       ....

The environment has additional components/services:
- **Incubator DNS Server** (incubator-domain): A DNS server that resolves queries for the 'edelivery.tech.ec.europa.eu' domain with the following ip 172.20.0.201.


## Running the PoC


    # Start the PoC environment
    docker compose -f uc-transition/docker-compose.yml  up -d

    # Stop the PoC environment
    docker compose -f uc-transition/docker-compose.yml down -v

    # 'clean restart' the PoC environment
    docker compose -f uc-transition/docker-compose.yml down -v && docker compose -f uc-transition/docker-compose.yml up -d

Before running starting the PoC environment, make sure that log files in the `logs` directory have read and write permissions for all users. If not, run the following command:

    chmod a+rw logs/*
    chmod a+rw uc-transition/logs/*

Simple smoke tests to resolve A records. The purpose of the test is to verify that the DNS server is running and resolving the DNS queries. Result for all queries should be the IP address 127.0.0.1

    # Test 1
    dig  @localhost -p 54 test.edelivery.tech.ec.europa.eu

in case dig is not locally installed it can be used dig from the client-with-rdns container:

    docker exec -it client-with-rdns dig @localhost test.edelivery.tech.ec.europa.eu


### Test: Use case 1

The test is to verify that the DNS server is running and resolving the DNS queries. Result for all queries should be the IP address

Resolve the DNS NAPTR records registered in the edelivery.tech.ec.europa.eu authoritative DNS server
Commands to resolve the NAPTR records for the domain edelivery.tech.ec.europa.eu:

    
    # Command 1
    dig @localhost -p 54 NAPTR IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    # Command 2
    dig @localhost -p 54 NAPTR IDUC2ABCE.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    # Command 3
    dig @localhost -p 54 NAPTR IDUC3ABCF.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    # Command 4
    dig @localhost -p 54 NAPTR IDUC4ABCG.iso6523-actorid-upis.edelivery.tech.ec.europa.eu

Responses follows the same order as the queries above:

    Response 1
    ;; ANSWER SECTION:
    IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!.*!http://127.0.0.1:8080/smp-inc-uc-01/!" .
    Response 2
    ;; ANSWER SECTION:
    IDUC2ABCE.iso6523-actorid-upis.edelivery.tech.ec.europa.eu. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!.*!http://127.0.0.1:8080/smp-inc-uc-02/!" .
    Response 3
    ;; ANSWER SECTION:
    IDUC3ABCF.iso6523-actorid-upis.edelivery.tech.ec.europa.eu. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!.*!http://127.0.0.1:8080/smp-inc-uc-03/!" .
    Response 4
    ;; ANSWER SECTION:
    IDUC4ABCG.iso6523-actorid-upis.edelivery.tech.ec.europa.eu. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!.*!http://127.0.0.1:8080/smp-inc-uc-04/!" .


### Test: Use case 2

The following test steps validates that the DNS records are by the incubator DNS server and are not resolved by the.
resolved by the ecosystem DNS server

    # Command 1: resolve with ecosystem top domain
    dig @localhost -p 54 NAPTR IDUC1ABCD.9954.iso6523.participants.ecosystem.org
    dig @localhost -p 54 NAPTR IDUC3ABCF.0151.iso6523.participants.ecosystem.org
    # Command 2:  resolve with incubator top domain
    dig @localhost -p 54 NAPTR IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu
    dig @localhost -p 54 NAPTR IDUC3ABCF.iso6523-actorid-upis.edelivery.tech.ec.europa.eu

Response:
    
    Response 1 (No answer section!)
    ;; AUTHORITY SECTION:
    ecosystem.org.          60      IN      SOA     ns1.ecosystem.org. root.ecosystem.org. 2023102801 3600 1800 1209600 86400

    Response 2 (Answer section)
    ;; ANSWER SECTION:
    IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!.*!http://127.0.0.1:8080/smp-inc-uc-01/!" .

In the following step the ecosystem DNS server is configured to redirect the subdomain 9954 to be resolved by the incubator DNS server. The configuration is done with 'nsupdate' command-line tool and the command.

    docker exec -it ecosystem-top-domain sh -c 'echo -e "server localhost\nzone ecosystem.org.\nupdate add  9954.iso6523.participants.ecosystem.org. 60  DNAME iso6523-actorid-upis.edelivery.tech.ec.europa.eu.\n    add 0151.iso6523.participants.ecosystem.org. 60  DNAME iso6523-actorid-upis.edelivery.tech.ec.europa.eu.\nsend" | nsupdate -4'

Explanation of the command:

To add records to the DNS server, the `nsupdate` command is used. To execute the in the `ecosystem-top-domain` container the docker command `docker exec -it ecosystem-top-domain` is used.

The following `nsupdate` command consists of the following parts:

- `sh -c echo -e `: Prints the update request to the standard shell output which is the input for the nsupdate. 
- The update request consists of the following parts:
  - `server localhost`: Specifies the DNS server to which the update request is sent.
  - `zone ecosystem.org.`: Specifies the zone to be updated.
  - `update`: 
    - `add  9954.iso6523.participants.ecosystem.org. 60  DNAME iso6523-actorid-upis.edelivery.tech.ec.europa.eu.`: Adds a DNAME record for the domain 9954.iso6523.participants.ecosystem.org. The DNAME record redirects the domain to the incubator DNS server.
    - `add  0151.iso6523.participants.ecosystem.org. 60  DNAME iso6523-actorid-upis.edelivery.tech.ec.europa.eu.`: Adds a DNAME record for the domain 0151.iso6523.participants.ecosystem.org. The DNAME record redirects the domain to the incubator DNS server.
  - `send`: Sends the update request to the DNS server.

After the configuration, the DNS records should be resolved by the ecosystem DNS server.

    # Command 1: resolve with ecosystem top domain
    dig @localhost -p 54 NAPTR IDUC1ABCD.9954.iso6523.participants.ecosystem.org
    dig @localhost -p 54 NAPTR IDUC3ABCF.0151.iso6523.participants.ecosystem.org
    
Responses:

    ;; ANSWER SECTION:
    9954.iso6523.participants.ecosystem.org. 60 IN DNAME iso6523-actorid-upis.edelivery.tech.ec.europa.eu.
    IDUC1ABCD.9954.iso6523.participants.ecosystem.org. 60 IN CNAME IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu.
    IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!.*!http://127.0.0.1:8080/smp-inc-uc-01/!" .

    ;; ANSWER SECTION:
    0151.iso6523.participants.ecosystem.org. 60 IN DNAME iso6523-actorid-upis.edelivery.tech.ec.europa.eu.
    IDUC3ABCF.0151.iso6523.participants.ecosystem.org. 60 IN CNAME IDUC3ABCF.iso6523-actorid-upis.edelivery.tech.ec.europa.eu.
    IDUC3ABCF.iso6523-actorid-upis.edelivery.tech.ec.europa.eu. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!.*!http://127.0.0.1:8080/smp-inc-uc-03/!" .


### Test: Use case 3

The following test steps validates that the DNS records are resolved by the ecosystem DNS server with the redirection to the incubator DNS server

    # Command 1: resolve with ecosystem top domain
    dig @localhost -p 54 NAPTR IDUC1ABCD.9954.iso6523.participants.ecosystem.org
    dig @localhost -p 54 NAPTR IDUC2ABCE.9954.iso6523.participants.ecosystem.org

Both queries should return the same result as in the previous step as example:

    ;; ANSWER SECTION:
    9954.iso6523.participants.ecosystem.org. 60 IN DNAME iso6523-actorid-upis.edelivery.tech.ec.europa.eu.
    IDUC1ABCD.9954.iso6523.participants.ecosystem.org. 60 IN CNAME IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu.
    IDUC1ABCD.iso6523-actorid-upis.edelivery.tech.ec.europa.eu. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!.*!http://127.0.0.1:8080/smp-inc-uc-01/!" .

With the following command the records are added to the ecosystem DNS server and the redirection is removed.

    docker exec -it ecosystem-top-domain sh -c 'echo -e "server localhost\nzone ecosystem.org.\nupdate delete 9954.iso6523.participants.ecosystem.org. DNAME \n add IDUC1ABCD.9954.iso6523.participants.ecosystem.org 60 IN NAPTR 100 10 \"U\" \"Meta:SMP\" \"!.*!http://127.0.0.1:8080/smp-inc-uc-01/!\" .\n add IDUC2ABCE.9954.iso6523.participants.ecosystem.org 60 IN NAPTR 100 10 \"U\" \"Meta:SMP\" \"!.*!http://127.0.0.1:8080/smp-inc-uc-02/!\" .\nsend" | nsupdate -4' 


Explanation of the command:

To add records to the DNS server, the `nsupdate` command is used. To execute the in the `ecosystem-top-domain` container the docker command `docker exec -it ecosystem-top-domain` is used.

The following `nsupdate` command consists of the following parts:

- `sh -c echo -e `: Prints the update request to the standard shell output which is the input for the nsupdate.
- The update request consists of the following parts:
  - `server localhost`: Specifies the DNS server to which the update request is sent.
  - `zone ecosystem.org.`: Specifies the zone to be updated.
  - `update`:
    - `delete 9954.iso6523.participants.ecosystem.org. DNAME`: Deletes the DNAME record for the domain 9954.iso6523.participants.ecosystem.org. 
      - `add IDUC1ABCD.9954.iso6523.participants.ecosystem.org 60 IN NAPTR 100 10 \"U\" \"Meta:SMP\" \"!.*!http://127.0.0.1:8080/smp-inc-uc-01/!\" .`: Adds a NAPTR record for the domain IDUC1ABCD.9954.iso6523.participants.ecosystem.org.
    - `add IDUC2ABCE.9954.iso6523.participants.ecosystem.org 60 IN NAPTR 100 10 \"U\" \"Meta:SMP\" \"!.*!http://127.0.0.1:8080/smp-inc-uc-02/!\" .`: Adds a NAPTR record for the domain IDUC2ABCE.9954.iso6523.participants.ecosystem.org. 
  - `send`: Sends the update request to the DNS server.


After the configuration, the DNS records are  resolved by the ecosystem DNS server.

    ;; ANSWER SECTION:
    IDUC1ABCD.9954.iso6523.participants.ecosystem.org. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!.*!http://127.0.0.1:8080/smp-inc-uc-01/!" .

and 

    ;; ANSWER SECTION:
    IDUC2ABCE.9954.iso6523.participants.ecosystem.org. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!.*!http://127.0.0.1:8080/smp-inc-uc-02/!" .


## Conclusion

The PoC environment showcases a gradual transition from the incubator domain to the federated DNS domain. Thanks to the partitioning of the federated DNS domain, this transition can be managed in a controlled manner by each partition at a time. During the transition, the existing services using the old 'incubator' domain are not effected.

The showcase does not cover the entire transition process, such as where new records should be recorded during the transition (whether in the new ecosystem domain or the old incubator domain). However, it provides a starting point for further test development.

It is also worth noting that during the transition, all records in the incubator domain can be resolved by any of the new partitioned ecosystem DNS top domains, as long as the DNAME redirection is in place for the partitioned domains.

For example, the hash value IDUC1ABCD is part of the subdomain 9954.iso6523.participants.ecosystem.org, but it can also be resolved by 0151.iso6523.participants.ecosystem.org, as long as the DNAME redirection for both domains remains in place.


