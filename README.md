# Dynamic discovery infrastructure with "federated DNS service" 


## Introduction

The goal of this project is to create a Dockerized environment for a proof of concept 
(PoC) that focuses on dynamic discovery infrastructure using federated SML-DNS. This 
PoC environment aims to simulate a federated DNS integration, incorporating the variants 
discussed by the OpenPeppol Working Group on Federated DNS services.

One of the objective of federated DNS services is to empower various independent DNS 
servers to handle DNS query resolution within the **business domain network**, also called 
as **digital ecosystems** (e.g. Peppol). This approach ensures scalability, robustness 
of the ecosystem, and data sovereignty, allowing different authorities—such as countries, 
regions, or organizations—to manage their own DNS records and resolve queries within the 
shared network. At the same time, the **ecosystem owner** retains the ability to enable or 
disable various DNS servers as part of the digital ecosystem.

In the long term, the PoC environment could be used for the integration tests and 
local development environment of the DDI (Dynamic Discovery Infrastructure) components
such are Service Metadata Locator component (SML) and Service Metadata Publisher 
component (SMP), Dynamic discovery client (DDC), and access point (AP).

Here is the list of addition cases that reuses the PoC environment:

- [Transition of the domain](docs/use-case-transition.md)

## Environment assumptions

### DNS Infrastructure

The PoC environment simulates a federated DNS service with the given top-level domain. 
The top-level domain represents the message exchange network within the **digital ecosystems**.
For example, in the PEPPOL network for e-invoice exchange it could  be **peppol.org** or
in the messaging network for european eHealth record exchange it could be **ehealth.eu**, etc. 

Because of the generic nature of the environment the example top-level domain, uses the 
top-level domain **ecosystem.org**  as example.


### Dynamic Discovery Client
In the DDI, the Dynamic Discovery Client (DDC) is tasked with resolving network 
participant exchange capability data, such as the participant’s AP URL address and 
the AP encryption/signing certificates. The DDC performs this discovery in two steps:

* **DNS lookup**: Using the DNS infrastructure, it lookup URL where the participant publishes its message exchange capability document (e.g., Peppol SMP documents, OASIS SMP documents, Oasis CPPA-CPP document, etc.).
* **Retrieval and Processing**: It then retrieves the document from the discovered URL and processes it to extract the necessary information for message submission.

In the initial phase of the PoC, this environment will focus on simulating the DNS lookup phase of the DDC. In subsequent phases, the PoC environment can be enhanced with SMP, SML and AP components.

In this initial phase, the DIG command-line tool will be used to query the DNS server and retrieve the final DNS record containing the SMP participant URL. The DIG (initially acronym for  Domain Information Groper) is maintained by the Internet Systems Consortium (ISC) as part of the Berkeley Internet Name Domain (BIND) software package. The DIG is primarily used for DNS troubleshooting and testing. It contains capabilities to query DNS servers to obtain details about domain names, IP addresses, mail exchanges, name servers, and other DNS records.


###  Participant Identifiers
The participant identifier is a unique identifier that is used to identify a network participant in the message exchange network and must be unique within the network. 

The PoC assumes that participant identifiers are composed of the following elements:

- **Catalog Identifier**: e.g., iso6523
- **Scheme in Catalog**: e.g., International Code Designator (ICD) for iso6523 such as 0088, 0195, 9914
- **Scheme-Specific Identifier** : e.g., 1234567890

### DNS Lookup Query

The DNS lookup query is constructed as follows:
NOTE: For the presentation of the rules the  augmented Backus–Naur  (ABNF) for 
Syntax is used (See the: [RFC 5234](https://www.ietf.org/rfc/rfc5234.txt).



    <DNS-QUERY> ::= <hash-over-(part-of?)identifier> "." <scheme-in-catalog> "." <catalog-identifier> "." <top-level-domain>

    <hash-over-(part-of?)identifier> ::= 1*63(ALPHA / DIGIT )
    <scheme-in-catalog> ::= 4DIGIT
    <catalog-identifier> ::= 1*63(ALPHA / DIGIT / "-")
    <top-level-domain> ::= 1*63(ALPHA / DIGIT / "-")    

Example

    ABCDE.0195.iso6523.participants.ecosystem.org

Where in the example above:

- **hash-over-(part-of?)identifier**: is ‘ABCDE’ (how the hash is calculated is out of scope in the initial  PoC stage, but it will be important part of the future steps)
- **scheme-in-catalog**: Scheme in Catalog is ‘0195’
- **catalog-identifier**: Catalog Identifier is ‘iso6523’
- **top-level-domain**: Top-Level Domain is ‘participants.ecosystem.org’


### DNS Domain Partitioning

For the case of iso6523, this approach allows the DNS domain to be partitioned into multiple subdomains by ISO6523 International Code Designator (ICD). The ICD uniquely identifies the authority which issued the network party identifier:

e.g. 
- **0088**: The Global Location Number (GLN) maintained by the  GS1
- **0195**: Singapore Nationwide elnvoice Framework
- **9914**: Austrian VAT identification number 
    
And in the context of the PoC, the DNS domain is partitioned into the following subdomains:

- **0088**.iso6523.participants.ecosystem.org
- **0195**.iso6523.participants.ecosystem.org
- **9914**.iso6523.participants.ecosystem.org
- ...

## Use cases

The PoC environment is designed to showcase various methods of subdomain delegation 
within DNS infrastructure, as well as different strategies for organizing internal 
DNS server records (e.g using CNAME for easier maintenance of final DNS record data).

### Use case 1: DNS records are registered in the top-level domain authoritative DNS server

The first use case involves registering the DNS record in the top-level authoritative DNS server.

The setup of the approach involves the setting up of the authoritative DNS server 
for the top-level domain **ecosystem.org** and configuring the DNS records for 
the subdomains **iso6523.participants.ecosystem.org**. 


**Hypothetical context**

The DNS server of the top-level domain, **ecosystem.org**, is responsible for resolving 
DNS queries for the subdomain **0088.iso6523.participants.ecosystem.org**. This setting 
reflects the current configuration of the SML service, where all participant identifiers
are registered within the domain's top-level DNS server.

### Use case 1.a: The final SMP data is registered in a single DNS record with CNAME redirection

In this scenario, the final SMP data is registered in a single DNS record and network participants 
are pointing to it using the CNAME record. This approach simplifies the maintenance of the final SMP
DNS record data, as all changes are made in a single location.

The setup of the approach involves  adding the dedicated SMP record  with subdomain 'publisher' and registering the participant record using the CNAME record to point to the SMP DNS record.


### Use case 2: Standard subdomain delegation using the NS record

Subdomain delegation involves assigning responsibility for a subdomain to a different DNS server. 
This process allows the subdomain to be managed independently of the parent domain. The setup 
of the approach involves the following steps:

- **Authoritative "subdomain zone" DNS Server Setup**: A dedicated authoritative DNS server is set up for the subdomain.
- **NS Records**: The parent domain’s DNS zone file is updated with NS (Name Server) records that point to the DNS servers which is authoritative for the subdomain.
- **Delegation**: Once the NS and (glue record if needed) are in place, DNS queries for the subdomain are directed to the designated DNS servers, which handle all DNS requests for that subdomain.

**Hypothetical context**

To illustrate a practical application of the approach, consider the following hypothetical context:

Singapore is establishing a platform called “e-invoice” for electronic invoice exchange. 
The objective of this platform is to integrate into the existing international electronic 
invoice exchange network, facilitating the exchange of electronic invoices both 
domestically and globally.

The global platform utilizes the ISO 6523 catalog to identify network participants. 
Since the discovery of participant message exchange capabilities is based on DNS 
lookup, the global platform employs the top-level domain DNS server **iso6523.participants.ecosystem.org** 
to resolve DNS queries in the format: **<hash-over-participant-id>.<ICD>.iso6523.participants.ecosystem.org**.
The result of the DNS lookup  provides the location (URL) of the participant message 
exchange capabilities document.

The Singapore platform establishes the ISO 6523 catalog scheme **0195** for participant 
identifiers registered in Singapore. To integrate the Singapore e-invoice network 
into the existing international network, they setup a dedicated authoritative DNS server
for the subdomain **0195.iso6523.participants.ecosystem.org** and request the top-level 
domain DNS server **.ecosystem.org** to delegate this subdomain DNS zone to the Singapore DNS server.

The Singapore DNS server then has control over the subdomain **0195.iso6523.participants.ecosystem.org** 
zone data and is responsible for resolving queries for this subdomain as part of the global network.


### Use case 2.a: The final SMP data is registered in a single DNS record with CNAME redirection

In this scenario, the final SMP data is registered in a single DNS record and network participants
are pointing to it using the CNAME record on delegated DNS server.

The setup of the approach involves  adding the dedicated SMP record within the subdomain 'publisher' and registering the participant record using the CNAME record to point to the SMP DNS record.

### Use case 3: DNAME subdomain delegation

DNAME delegation is a method of delegating using the redirect an entire subtree of the DNS namespace to another domain. Unlike the CNAME record, which only aliases a single node, the DNAME record applies to all subdomains under a specified domain. 

The setup involves the following steps:
- **Setup of the Authoritative DNS domain server which is NOT subdomain of the ecosystem top domain DNS server**: A dedicated custom authoritative DNS server is set up for the custom DNS domain.
- **DNAME Record**: The ecosystem authoritative  domain’s DNS zone  is updated with a DNAME record that points to the custom target domain.
- **Delegation**: Once the DNAME record is in place, DNS queries for the subdomain are redirected to the target domain, which handles all DNS requests for subdomain of the ecosystem.

**Hypothetical context**

To illustrate a practical application of the approach, consider the following hypothetical context:

The Austrian government has already established a G2B platform for companies to
conduct day-to-day business message exchange with the government. This network
includes services such as electronic invoicing, procurement, health insurance-related 
services, e-justice mail exchange, and other business message transactions. To identify
domestic network participants, the Austrian government uses the ISO 6523 catalog 
schemes 9914 and 9915, with discovery lookups based on DNS queries in the format:
<hash-over-participant-id>.{(9914 / 9915 ... )}.iso6523.b2g.at.

Now the Austrian government aims to integrate the G2B platform (identifiers from 
catalog 9914) into the existing international electronic invoice exchange network 
with the top-level domain “ecosystem.org”. Since they already maintain a DNS server,
they prefer not to set up a new DNS server for the subdomain **9914.iso6523.participants.ecosystem.org**. 
Instead, they request the top-level domain DNS server **.ecosystem.org** to use 
a DNAME record to delegate the subdomain **9914.iso6523.participants.ecosystem.org** 
to the existing DNS domain **9914.iso6523.b2g.at**.

This approach allows the Austrian government to reuse the same DNS server for 
other services on an EU or global scale, such as health insurance, e-justice mail 
exchange, and other business transactions.

### Use case 3.a: The final SMP data is registered in a single DNS record with CNAME redirection

In this scenario, the final SMP data is registered in a single DNS record and network participants
are pointing to it using the CNAME record on delegated DNS server.

The setup of the approach involves adding the dedicated SMP record within the subdomain 'publisher' and registering the participant record using the CNAME record to point to the SMP DNS record.

### Use case 3.b: The local DNS resolves record for initial domain

In this scenario, the local "DNS" domain can be used to resolve the DNS records for the initial domain.

**Hypothetical context**

The Austrian government has already established a G2B platform **9914.iso6523.b2g.at**,
and it still wants to use the same DNS server to resolve the DNS records for domestic services 
on the subdomain **9914.iso6523.b2g.at**.

### Use case 3.c: The local DNS resolves record for initial domain with the "internal CNAME redirection"

In this scenario, the final SMP data is registered in a single DNS record and network participants
are pointing to it using the CNAME record on the initial domain.

The setup of the approach involves the configuration steps from the Use case 3.a and in this
use case, the resolution of the DNS records is done with the initial DNS domain.

## Environment Setup

The PoC environment is made to simulate a federated DNS service with top domain 
name ecosystem.org. And it contains two different DNS servers, one is using the 
standard subdomain delegation and the other is using the DNAME subdomain delegation. 

The environment consists of the following components/services: 

- **Resolver DNS Server** (client-with-rdns): A DNS server that resolves queries for the 'ecosystem.org' domain. 
- **Ecosystem DNS Server** (ecosystem-top-domain): an authoritative DNS server for top domain 'ecosystem.org'. The server is responsible for resolving queries for the subdomains 0088.iso6523.participants.ecosystem.org.
- **NS Delegated DNS Server**  (invoice-sg): an authoritative DNS server for the subdomain 0195.iso6523.participants.ecosystem.org.
- **DNAME Delegated DNS Server** (vat-num-at): an authoritative DNS server for the subdomain 9914.iso6523.participants.ecosystem.org.
 
The docker environment is using the "docker bridge network" with the subnet 172.20.0.0/16. and the services are running in the following IP addresses:
- **Resolver DNS Server**:  172.20.0.10 (DNS service is exposed in port 54 to host machine)
- **Ecosystem DNS Server**: 172.20.0.2
- **NS Delegated DNS Server**: 172.20.0.101
- **DNAME Delegated DNS Server**: 172.20.0.102

NOTE: When running the environment on the local machine, make sure that the subnet is not overlapping with any other local network.


### Data/DNS configuration

The ecosystem-top-domain DNS has the following test participant/SMP DNS records:

    ;Use case 1
    UC1XABCD.0088.iso6523.participants.ecosystem.org NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc1/!" .

    ;Use case 1.a
    smp-uc1a.publisher.0088.iso6523.participants.ecosystem.org NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc1a/!" .
    UC1AXABCD.0088.iso6523.participants.ecosystem.org CNAME smp-uc1a.publisher.0088.iso6523.participants.ecosystem.org
 
and subdomain delegation DNS records are as follows:

    ;Use case 2.x; subdomain delegation
    0195.iso6523.participants IN NS ns1.0195.iso6523.participants.ecosystem.org.
    ; a glue record for the name server
    ns1.0195.iso6523.participants IN A 172.20.0.101
    
    ;Use case 3.x; redirect subdomain using DNAME
    9914.iso6523.participants IN  DNAME 9914.iso6523.g2b.at.


The invoice-sg DNS has the following test participant/SMP DNS records:

    ;Use case 2
    UC2XABCD.0195.iso6523.participants.ecosystem.org NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc2/!" .

    ;Use case 2.a
    smp-uc2a.publisher.0195.iso6523.participants.ecosystem.org NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc2a/!" .
    UC2AXABCD.0195.iso6523.participants.ecosystem.org CNAME smp-uc2a.publisher.0195.iso6523.participants.ecosystem.org

The vat-num-at DNS has the following test participant/SMP DNS records:

    ;Use case 3, 3.b
    UC3XABCD.9914.iso6523.g2b.at NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-at/!" .

    ;Use case 3.a, 3.c
    smp-uc3a.publisher.9914.iso6523.g2b.at NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc3a/!" .
    UC3AXABCD.9914.iso6523.g2b.at CNAME smp-uc3a.publisher.9914.iso6523.g2b.at

Note: with combination of the DNAME record, the DNS server will resolve the following DNS records:

    UC3XABCD.9914.iso6523.participants.ecosystem.org
    UC3AXABCD.9914.iso6523.participants.ecosystem.org



The following dig command must be used to query the DNS server (please note: Resolver DNS Server exposes DNS service in port 54):

    dig @localhost -p 54 <DNS-QUERY> NAPTR
    # in case dig is not locally installed it can be used dig from the container
    # Note: DNS service is listening on standard port 53 inside the container and defining port 54 is not needed.
    docker exec -it client-with-rdns dig @localhost <DNS-QUERY> NAPTR
    
    # Test: Use case 1
    dig @localhost -p 54 UC1XABCD.0088.iso6523.participants.ecosystem.org NAPTR
    # Expected result: NAPTR Record with value: "!^.*$!http://127.0.0.1:8080/smp-uc1/!"

    # Test: Use case 1.a
    dig @localhost -p 54 UC1AXABCD.0088.iso6523.participants.ecosystem.org NAPTR
    # Expected result: NAPTR Record with value: "!^.*$!http://127.0.0.1:8080/smp-uc1a/!"

    # Test: Use case 2
    dig @localhost -p 54 UC2XABCD.0195.iso6523.participants.ecosystem.org NAPTR
    # Expected result: NAPTR Record with value: "!^.*$!http://127.0.0.1:8080/smp-uc2/!"

    # Test: Use case 2.a
    dig @localhost -p 54 UC2AXABCD.0195.iso6523.participants.ecosystem.org NAPTR
    # Expected result: NAPTR Record with value: "!^.*$!http://127.0.0.1:8080/smp-uc2a/!"

    # Test: Use case 3
    dig @localhost -p 54 UC3XABCD.9914.iso6523.participants.ecosystem.org NAPTR
    # Expected result: NAPTR Record with value: "!^.*$!http://127.0.0.1:8080/smp-uc3/!"

    # Test: Use case 3.a
    dig @localhost -p 54 UC3AXABCD.9914.iso6523.participants.ecosystem.org NAPTR
    # Expected result: NAPTR Record with value: "!^.*$!http://127.0.0.1:8080/smp-uc3a/!"

    # Test: Use case 3.b
    dig @localhost -p 54 UC3XABCD.9914.iso6523.g2b.at NAPTR
    # Expected result: NAPTR Record with value: "!^.*$!http://127.0.0.1:8080/smp-uc3a/!"

    # Test: Use case 3.c
    dig @localhost -p 54 UC3AXABCD.9914.iso6523.g2b.at NAPTR
    # Expected result: NAPTR Record with value: "!^.*$!http://127.0.0.1:8080/smp-uc3a/!"

    

## Running the PoC

The PoC environment can be started using the following command (linux OS):

    # Start the PoC environment
    docker compose up -d

    # Stop the PoC environment
    docker compose down -v

    # 'clean restart' the PoC environment
    docker compose down -v && docker compose up -d

    
Simple smoke tests to resolve A records. The purpose of the test is to verify that the DNS server is running and resolving the DNS queries. Result for all queries should be the IP address 127.0.0.1

    # Test 1
    dig  @localhost -p 54 test.0088.iso6523.participants.ecosystem.org
    # Test 2
    dig  @localhost -p 54 test.0195.iso6523.participants.ecosystem.org
    # Test 3
    dig  @localhost -p 54 test.9914.iso6523.g2b.at
    # Test 4
    dig  @localhost -p 54 test.9914.iso6523.participants.ecosystem.org

in case dig is not locally installed it can be used dig from the client-with-rdns container:

    docker exec -it client-with-rdns dig @localhost test.0088.iso6523.participants.ecosystem.org
    docker exec -it client-with-rdns dig @localhost test.0195.iso6523.participants.ecosystem.org
    docker exec -it client-with-rdns dig @localhost test.9914.iso6523.g2b.at
    docker exec -it client-with-rdns dig @localhost test.9914.iso6523.participants.ecosystem.org


### Test: Use case 1

Resolve the DNS records registered in the top-level domain authoritative DNS server
Command:

    dig @localhost -p 54 UC1XABCD.0088.iso6523.participants.ecosystem.org NAPTR

Response:

    ;; ANSWER SECTION:
    UC1XABCD.0088.iso6523.participants.ecosystem.org. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc1/!" .

The result of the query returns the expected NAPTR record value.

### Test: Use case 1.a

Resolve the DNS records registered in the top-level domain authoritative DNS server using CNAME redirection
Command:

    dig @localhost -p 54 UC1AXABCD.0088.iso6523.participants.ecosystem.org NAPTR

Response:

    ;; ANSWER SECTION:
    UC1AXABCD.0088.iso6523.participants.ecosystem.org. 60 IN CNAME smp-uc1a.publisher.0088.iso6523.participants.ecosystem.org.
    smp-uc1a.publisher.0088.iso6523.participants.ecosystem.org. 60 IN NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc1a/!" .


The result of the query returns the expected NAPTR record value.

### Test: Use case 2

Resolve the DNS records registered in the NS delegated DNS server

Command:

    dig @localhost -p 54 UC2XABCD.0195.iso6523.participants.ecosystem.org NAPTR

Response:

    ;; ANSWER SECTION:
    UC2XABCD.0195.iso6523.participants.ecosystem.org. 86400 IN NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc2/!" .

The result of the query returns the expected NAPTR record value.

### Test: Use case 2.a

Resolve the DNS records registered in the NS delegated DNS server using CNAME redirection
Command:

    dig @localhost -p 54 UC2AXABCD.0195.iso6523.participants.ecosystem.org NAPTR

Response:

    ;; ANSWER SECTION:
    UC2AXABCD.0195.iso6523.participants.ecosystem.org. 86400 IN CNAME smp-uc2a.publisher.0195.iso6523.participants.ecosystem.org.
    smp-uc2a.publisher.0195.iso6523.participants.ecosystem.org. 86400 IN NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc2a/!" .

The result of the query returns the expected NAPTR record value.

### Test: Use case 3

Resolve the DNS records registered in the "DNAME delegated" DNS server
Command:

    dig @localhost -p 54 UC3XABCD.9914.iso6523.participants.ecosystem.org NAPTR

Response:

    ;; ANSWER SECTION:
    9914.iso6523.participants.ecosystem.org. 60 IN DNAME 9914.iso6523.g2b.at.
    UC3XABCD.9914.iso6523.participants.ecosystem.org. 60 IN CNAME UC3XABCD.9914.iso6523.g2b.at.
    UC3XABCD.9914.iso6523.g2b.at. 84632 IN  NAPTR   100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc3/!" .

The result of the query returns the expected NAPTR record value.

### Test: Use case 3.a

Resolve the DNS records registered in the "DNAME delegated" DNS server using CNAME 
redirection on the target DNS server

Command:

    dig @localhost -p 54 UC3AXABCD.9914.iso6523.participants.ecosystem.org NAPTR

Response

    ;; ANSWER SECTION:
    9914.iso6523.participants.ecosystem.org. 60 IN DNAME 9914.iso6523.g2b.at.
    UC3AXABCD.9914.iso6523.participants.ecosystem.org. 60 IN CNAME UC3AXABCD.9914.iso6523.g2b.at.
    UC3AXABCD.9914.iso6523.g2b.at. 84601 IN CNAME   smp-uc3a.publisher.9914.iso6523.g2b.at.
    smp-uc3a.publisher.9914.iso6523.g2b.at. 84601 IN NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc3a/!" .

The result of the query returns the expected NAPTR record value.

### Test: Use case 3.b

Resolve the DNS records registered with initial DNS domain '9914.iso6523.g2b.at'
Command:

    dig @localhost -p 54 UC3XABCD.9914.iso6523.g2b.at NAPTR

Response:

    ;; ANSWER SECTION:
    UC3XABCD.9914.iso6523.g2b.at. 84473 IN  NAPTR   100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc3/!" .

### Test: Use case 3.c

Resolve the DNS records registered with initial DNS domain '9914.iso6523.g2b.at'
using CNAME redirection on the target DNS server
Command:

    dig @localhost -p 54 UC3AXABCD.9914.iso6523.g2b.at NAPTR

Response: 

    ;; ANSWER SECTION:
    UC3AXABCD.9914.iso6523.g2b.at. 84462 IN CNAME   smp-uc3a.publisher.9914.iso6523.g2b.at.
    smp-uc3a.publisher.9914.iso6523.g2b.at. 84462 IN NAPTR 100 10 "U" "Meta:SMP" "!^.*$!http://127.0.0.1:8080/smp-uc3a/!" .

The result of the query returns the expected NAPTR record value.

## Conclusion

The PoC environment demonstrates the setup of a federated DNS service with the top-level domain ecosystem.org. It showcases various subdomain delegation methods, including standard NS delegation of the subdomain  and DNAME redirection.

Tests confirm that both delegation methods effectively resolve DNS NAPTR records. Additionally, internal DNS server record organization using CNAME records to dedicated SMP’s NAPTR records functions as expected.
