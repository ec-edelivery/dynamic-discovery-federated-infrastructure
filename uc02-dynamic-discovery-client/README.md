# Participant discovery with the Dynamic Discovery Client


NOTE: This document is currently a work in progress and subject to changes.

## Introduction

The Dynamic Discovery Client (DDC) is a tool designed to locate a participant's capability document (e.g. Peppol SMP document, Oasis SMP 1.0/2.0 document, OASIS CPPA-CPP, ...) using dynamic discovery infrastructure. It can be developed as CommanLine tool or as library to be used as integral part of the Access Points implementation featuring dynamic discovery.

The purpose of the following use cases is to validate whether existing DDC sample implementation can be used with the new federated DNS infrastructure. Since the exact partitioning of the DNS domain is yet to be defined, these use cases are designed to test various DNS instance setups using the NS, DNAME, and CNAME records to locate the participant's capability document and the "DNS partitions are provided just as various top DNS domains like: `0088.iso6523.participants.ecosystem.org`, `0195.iso6523.participants.ecosystem.org`, and `9914.iso6523.participants.ecosystem.org` in current tests. 

After adopting the federated DNS model, the top DNS domain will be a single domain, such as `participants.ecosystem.org`. The partitioning/DNS subdomains will be managed automatically by the DDC based on the participant identifier and ecosystem DNS query rules. However, this is not yet the case in the following use cases.

In the following use cases, we will use the existing [eDelivery DDC example implementation](https://ec.europa.eu/digital-building-blocks/code/projects/EDELIVERY/repos/uc02-dynamic-discovery-client/browse) to find the participant's capability document location via the new DNS infrastructure. The eDelivery DDC employs the [dnsjava library](https://github.com/dnsjava/dnsjava) for DNS resolution. Consequently, all other DDC implementations based on the dnsjava library should yield the same results.

### Participant identifiers

The participant identifier is a unique token in the network used to locate a participant's capability document within the network. The base input for the DNS query is the hash value of the identifier. Therefore, it is crucial to properly format, encode and normalize the identifier value before calculating the hash value, as this has greate affects the hash's value.

Withing the use cases we will use two different 'formats' the same participant identifier based on ISO 6523 identifiers: **Peppol participant identifier** and **ebCore party identifier**.
 
In the following chapters, we will briefly summarize the syntax rules for these identifiers and how to use them in the DNS query.


#### Peppol participant identifier

The Peppol participant identifier is  defined in the:
https://docs.peppol.eu/edelivery/policies/PEPPOL-EDN-Policy-for-use-of-identifiers-4.3.0-2024-10-03.pdf

PEPPOL identifiers consist of two parts: the scheme and the identifier, separated by a double colon (::). The scheme is always "iso6523-actorid-upis". The identifier part value is further divided into two sections, separated by a colon (:):

1. The first section is the ISO 6523 ICD code (e.g., 0195).
2. The second section is the participant's identifier within the network (e.g., 1234567890 for a participant with the ICD code 0195).
For example: 0195:1234567890.


When constructing the DNS (NAPTR) query for the Peppol participant identifier, the identifier must be normalized and encoded as follows :

    DNS-QUERY ::= <HASH-OVER-IDENTIFIER-VALUE> "." <SCHEME> "." <TOP-LEVEL-DOMAIN>

    ASH-OVER-IDENTIFIER-VALUE ::= base32(sha256(lowerCase(IDENTIFIER-VALUE)))
    IDENTIFIER-VALUE ::= <ICD> ':' <IDENTIFIER>
    ICD ::= 4DIGIT 
    IDENTIFIER ::= 1*63(ALPHA / DIGIT / SPECIAL_CHAR)
    SCHEME ::= iso6523-actorid-upis 
    TOP-LEVEL-DOMAIN ::= 1*63(ALPHA / DIGIT / "-" / ".")    

Example (for the Peppol participant identifier iso6523-actorid-upis::0088:test01):

    LMHBM64R2VOF2IJIOGG2FXVWGYE42GF3CT7UF6EMOEWDS7ID3I2A.iso6523-actorid-upis.0088.iso6523.participants.ecosystem.org

Where in the example above:

- **hash-over-identifier-value**: is ‘LMHBM64R2VOF2IJIOGG2FXVWGYE42GF3CT7UF6EMOEWDS7ID3I2A’ where: base32(sha256(lowerCase(identifier-value))) 
- **ICD**: The ISO 6523 International Code Designator (ICD) for issuing identifier authority ‘0195’
- **scheme**: Peppol defines the scheme as ‘iso6523-actorid-upis’
- **top-level-domain**: Top-Level Domain  is ‘0088.iso6523.participants.ecosystem.org’ Please note that the top level structure in the example contains '0088.iso6523'. In the future, the top-level domain will be just the "participants.ecosystem.org", and the partitioning will be managed automatically by the DDC based on the participant identifier and ecosystem DNS query rules.



#### URN format: ebCore party identifier

Uniform Resource Names (URNs) format is defined the [RFC 8141](https://www.rfc-editor.org/rfc/rfc8141) and is used in various standards to create unique identifiers for resources with the following characteristics:

- Persistence: URNs are designed to be long-lasting, ensuring that the identifier remains valid even if the resource's location changes.
- Uniqueness: Each URN is globally unique, preventing conflicts and ensuring that each resource can be distinctly identified.
- Namespace Management: URNs are assigned within specific namespaces, which are managed to maintain consistency and avoid duplication.

Just as example (but not with intention to be used as network participant identifiers), here are some wide-spread URN identifiers examples:

ISBN (International Standard Book Number): Used to uniquely identify books. For example, urn:isbn:0451450523.
ISSN (International Standard Serial Number): Used for periodicals and serial publications. For example, urn:issn:1234-5678.
UUID (Universally Unique Identifier): Used to identify information in computer systems. For example, urn:uuid:6ba7b810-9dad-11d1-80b4-00c04fd430c8.
OID (Object Identifier): Used in various standards to uniquely identify objects. For example, urn:oid:1.3.6.1.4.1.


The ebCore party identifier is defined in the [OASIS ebCore Party Identifier Type](http://docs.oasis-open.org/ebcore/PartyIdType/v1.0/PartyIdType-1.0.html) specification. The ebCore party identifier is a URN-based identifier that uniquely identifies a party in the ebCore messaging infrastructure. The ebCore party identifier has the following format:

    urn:oasis:tc:ebcore:partyid-type:<catalog-identifier>:<scheme-in-catalog>:<scheme-specific-identifier>

in case of ISO653 ICD code the format is:

    IDENFITIFER ::= 'urn:oasis:tc:ebcore:partyid-type:iso6523' ':' <ICD> ':' <IDENTIFIER>

where:
    
    ICD ::= 4DIGIT 
    IDENTIFIER ::= 1*63(ALPHA / DIGIT / SPECIAL_CHAR")

Example:

    urn:oasis:tc:ebcore:partyid-type:iso652:0088:test01

When constructing the DNS (NAPTR) query for the ebCore party identifier, the identifier must be normalized and encoded as follows:

    DNS-QUERY ::= <HASH-OVER-IDENTIFIER-VALUE> "." <TOP-LEVEL-DOMAIN>

    HASH-OVER-IDENTIFIER-VALUE ::= base32(sha256(lowerCase(IDENTIFIER)))
    IDENTIFIER ::= 'urn:oasis:tc:ebcore:partyid-type:iso652:' <ICD> ':' <IDENTIFIER>
    ICD ::= 4DIGIT
    IDENTIFIER ::= 1*63(ALPHA / DIGIT / SPECIAL_CHAR)
    TOP-LEVEL-DOMAIN ::= 1*63(ALPHA / DIGIT / "-" / ".")

Example (for the participant identifier urn:oasis:tc:ebcore:partyid-type:iso652:0088:test01)) for top domain '0088.iso6523.participants.ecosystem.org'. Please note that the top level structure in the example contains '0088.iso6523'. In the future, the top-level domain will be just the "participants.ecosystem.org", and the partitioning will be managed automatically by the DDC based on the participant identifier and ecosystem DNS query rules.

    NTPFMJWLL2HIEYCKLIBVAJLW2SJXZQGFD7P53PN75FYF5GHUWSCQ.0088.iso6523.participants.ecosystem.org


## Use cases

The following use cases describe how to use the DDC to locate a participant's capability document using the new federated DNS infrastructure. The use cases are based on the Peppol participant identifier and the ebCore party identifier.



### Use case 1: DNS records are registered in the top-level domain authoritative DNS server (Peppol participant identifier)

In this use case, the participant DNS NAPTR record is registered with the authoritative DNS server for the top-level domain. The DDC's DNS Lookup retrieve NAPTR records, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.


### Use case 1.a: DNS records are registered in the top-level domain authoritative DNS server (Peppol participant identifier with CNAME)

In this use case, the participant DNS NAPTR record is registered with the authoritative DNS server for the top-level domain. The records is CNAME type which points to publisher 'SMP' NAPTR record. The DDC participant's DNS Lookup retrieve SMP's NAPTR record, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.


### Use case 1.b: DNS records are registered in the top-level domain authoritative DNS server (ebCore type participant identifier)

In this use case, the participant DNS NAPTR record is registered with the authoritative DNS server for the top-level domain. The DDC's DNS Lookup retrieve NAPTR records, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.


### Use case 1.c: DNS records are registered in the top-level domain authoritative DNS server (ebCore type participant identifier with CNAME)

In this use case, the participant DNS NAPTR record is registered with the authoritative DNS server for the top-level domain. The records is CNAME type which points to publisher 'SMP' NAPTR record. The DDC participant's DNS Lookup retrieve SMP's NAPTR record, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.

### Use case 2: Standard subdomain delegation using the NS record (Peppol participant identifier)

In this use case, the participant DNS NAPTR record is registered with the subdomain authoritative DNS server. The subdomain is redirected from the top domain using the DNS NS record.  

The DDC's DNS Lookup retrieve NAPTR records, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.

### Use case 2.a: Standard subdomain delegation using the NS record (Peppol participant identifier with CNAME)

In this use case, the participant DNS NAPTR record is registered with the subdomain authoritative DNS server. The subdomain is redirected from the top domain using the DNS NS record.

The records is CNAME type which points to publisher 'SMP' NAPTR record. The DDC participant's DNS Lookup retrieve SMP's NAPTR record, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.


### Use case 2.b: Standard subdomain delegation using the NS record (ebCore type participant identifier)

In this use case, the participant DNS NAPTR record is registered with the subdomain authoritative DNS server. The subdomain is redirected from the top domain using the DNS NS record.

The DDC's DNS Lookup retrieve NAPTR records, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.


### Use case 2.c: Standard subdomain delegation using the NS record (ebCore type participant identifier with CNAME)

In this use case, the participant DNS NAPTR record is registered with the subdomain authoritative DNS server. The subdomain is redirected from the top domain using the DNS NS record.

The records is CNAME type which points to publisher 'SMP' NAPTR record. The DDC participant's DNS Lookup retrieve SMP's NAPTR record, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.


### Use case 3: Standard subdomain delegation using the NS record (Peppol participant identifier)

In this use case, the participant DNS NAPTR record is registered with the subdomain authoritative DNS server. The subdomain is redirected from the top domain using the DNS NS record.

The DDC's DNS Lookup retrieve NAPTR records, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.

### Use case 3.a: Standard subdomain delegation using the NS record (Peppol participant identifier with CNAME)

In this use case, the participant DNS NAPTR record is registered with the subdomain authoritative DNS server. The subdomain is redirected from the top domain using the DNS NS record.

The records is CNAME type which points to publisher 'SMP' NAPTR record. The DDC participant's DNS Lookup retrieve SMP's NAPTR record, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.


### Use case 3.b: Standard subdomain delegation using the NS record (ebCore type participant identifier)

In this use case, the participant DNS NAPTR record is registered with the subdomain authoritative DNS server. The subdomain is redirected from the top domain using the DNS NS record.

The DDC's DNS Lookup retrieve NAPTR records, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.


### Use case 3.c: Standard subdomain delegation using the NS record (ebCore type participant identifier with CNAME)

In this use case, the participant DNS NAPTR record is registered with the subdomain authoritative DNS server. The subdomain is redirected from the top domain using the DNS NS record.

The participant record is a CNAME type which points to publisher 'SMP' NAPTR record. The DDC participant's DNS Lookup retrieve SMP's NAPTR record, which contain information about the participant's URL. The URL specified in the NAPTR record directs to the valid location of the participant's capability document, which the DDC successfully retrieves.



## Environment Setup

To execute the tests for the use cases, the DNS infrastructure as described in the [README.md](../README.md) was
updated with following records:

The following records were added to the DNS infrastructure:

The **ecosystem-top-domain** DNS the following test participant/SMP DNS records were added to the zone:

 - For the participant identifiers: **urn:oasis:names:tc:ebcore:partyid-type:iso6523:0088:test01** and **iso6523-actorid-upis::0088:test01** the direct NAPTR record is registered in the top-level domain authoritative DNS server with domains: `NTPFMJWLL2HIEYCKLIBVAJLW2SJXZQGFD7P53PN75FYF5GHUWSC.0088.iso6523.participants.ecosystem.org.` and `LMHBM64R2VOF2IJIOGG2FXVWGYE42GF3CT7UF6EMOEWDS7ID3I2A.iso6523-actorid-upis.0088.iso6523.participants.ecosystem.org.`
- For the participant identifiers: **urn:oasis:names:tc:ebcore:partyid-type:iso6523:0088:test02** and **iso6523-actorid-upis::0088:test02**  the following CNAME records pointing to SMP's NAPTR record domain: `AEY47QMI5YC46ORUMD54WGE6NYT42B57TXXSF3H63OP7FL7ANR3A.0088.iso6523.participants.ecosystem.org.` and
`PUTEUP6A7HSJKCCIAOPTTGURPR5JO253IYZGAMRE2MZNUZMIA7JA.iso6523-actorid-upis.0088.iso6523.participants.ecosystem.org.`

The **NS Delegated DNS Serve** DNS the following test participant/SMP DNS records were added to the zone:

- For the participant identifiers: **urn:oasis:names:tc:ebcore:partyid-type:iso6523:0195:test01** and **iso6523-actorid-upis::0195:test01** the direct NAPTR record is registered in the top-level domain authoritative DNS server with domains: `SW7FCYYKJI7YP27JILCJRNPIODTJYYO2DH3CAVWPSNPX3GJKGNZA.0195.iso6523.participants.ecosystem.org.` and `RYATFMWWQQHEY4T7VPPCXY7Z36T2FOL6QYXRGYF3V7S5LGJUAH2Q.iso6523-actorid-upis.0195.iso6523.participants.ecosystem.org.`
- For the participant identifiers: **urn:oasis:names:tc:ebcore:partyid-type:iso6523:0195:test02** and **iso6523-actorid-upis::0195:test02** the following CNAME records pointing to SMP's NAPTR record domain:  `SWDXXVXUUTFABXJAAWCM4EUDZJUMNLUWJ3HZZY7QARWGRKA7Q4HQ.0195.iso6523.participants.ecosystem.org.` and
`SQOK3QIXO5V26IRVUCVR2GJVZNVR5AFNB57ABHELYAI72ZIQ7ITQ.iso6523-actorid-upis.0195.iso6523.participants.ecosystem.org.`

The **'DNAME Delegated' DNS Server** DNS the following test participant/SMP DNS records were added to the zone:

- For the participant identifiers: **urn:oasis:names:tc:ebcore:partyid-type:iso6523:9914:test01** and **iso6523-actorid-upis::9914:test01** the direct NAPTR record is registered in the top-level domain authoritative DNS server with domains: `SXURSAE2VXDDT4KMND6H3CLAIEYULN5JQ6RFNJIG374NJARGSF6Q.9914.iso6523.g2b.at.` and `EMAOWJNPC73TKW737YRUFA6X2XFP5N6NBJFGWLFKY74CR55IIF5A.iso6523-actorid-upis.9914.iso6523.g2b.at.`
- For the participant identifiers: **urn:oasis:names:tc:ebcore:partyid-type:iso6523:9914:test02** and **iso6523-actorid-upis::9914:test02** the following CNAME records pointing to SMP's NAPTR record domain:  `GBDLL6QCELDM5JLQCWGP5CONIVXDP6BV2NZWWWI6BY5SFMNUYN7A.9914.iso6523.g2b.at.` and
  `57PSJISUOE7GR4UXE2M7IBKNLQV5CZS55QOIHAH3G67JVDOKTY3A.iso6523-actorid-upis.9914.iso6523.g2b.at.`

All NAPTR records are directed to the 'SMP URL' where the capability documents are hosted. In this use case, GitHub serves as the SMP. This demonstrates that the SMP approach is also adaptable to the configuration-as-code paradigm commonly used in microservice environments. The "GitHub SMP" address is: `https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/`


### Prerequisites

The DNS infrastructure is set up as described in the [DNS infrastructure documentation](../README.md).

- Java 8 or later (The test were performed with Java 11)
- Get dynamic discovery client

      wget -O ddc.jar https://ec.europa.eu/digital-building-blocks/artifact/repository/eDelivery/eu/europa/ec/dynamic-discovery/dynamic-discovery-cli/2.3/dynamic-discovery-cli-2.3.jar

for more information about the DDC see video guide [eDelivery Dynamic Discover Client (DDC)](https://ec.europa.eu/digital-building-blocks/sites/display/EDELCOMMUNITY/DomiSMP+5.0+video+guides.+Released+on+19+March+2024)


## Running the PoC

The PoC environment can be started using the following command (linux OS):

    # Start the PoC environment
    docker compose up -d

    # Stop the PoC environment
    docker compose down -v

    # 'clean restart' the PoC environment
    docker compose down -v && docker compose up -d

### Test: Use case 1

Resolve the DNS records registered in the **top-level domain authoritative DNS server** using the Peppol participant identifier format
Test DNS resolution:

Command:
    
        java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri 0088:test01 -rs iso6523-actorid-upis -d 0088.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='0088:test01', scheme='iso6523-actorid-upis'}] and domain: [0088.iso6523.participants.ecosystem.org]

    NAPTR query: LMHBM64R2VOF2IJIOGG2FXVWGYE42GF3CT7UF6EMOEWDS7ID3I2A.iso6523-actorid-upis.0088.iso6523.participants.ecosystem.org
    LMHBM64R2VOF2IJIOGG2FXVWGYE42GF3CT7UF6EMOEWDS7ID3I2A.iso6523-actorid-upis.0088.iso6523.participants.ecosystem.org.      60      IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .

Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):
        
    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri 0088:test01 -rs iso6523-actorid-upis -d 0088.iso6523.participants.ecosystem.org -t NAPTR -o test-uc01.xml
    
Response:
The file test-uc01.xml was created with corresponding capability document retrieved from the 'Github SMP'.


### Test: Use case 1.a

Resolve the DNS records registered in the **top-level domain authoritative DNS server** using the OASIS EBCore party identifier format.
Test DNS resolution:

Command:

        java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri test01 -rs urn:oasis:names:tc:ebcore:partyid-type:iso6523:0088 -d 0088.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='test01', scheme='urn:oasis:names:tc:ebcore:partyid-type:iso6523:0088'}] and domain: [0088.iso6523.participants.ecosystem.org]

    NAPTR query: NTPFMJWLL2HIEYCKLIBVAJLW2SJXZQGFD7P53PN75FYF5GHUWSCQ.0088.iso6523.participants.ecosystem.org
    NTPFMJWLL2HIEYCKLIBVAJLW2SJXZQGFD7P53PN75FYF5GHUWSCQ.0088.iso6523.participants.ecosystem.org.   60      IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!"

Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:0088:test01 -d 0088.iso6523.participants.ecosystem.org -t NAPTR -o test-uc01a.xml

Response:
The file test-uc01a.xml was created with corresponding capability document retrieved from the 'Github SMP'.

### Test: Use case 1.b

Resolve the DNS records registered in the **top-level domain authoritative DNS server** using the Peppol participant identifier format.
Test DNS resolution:

Command:

    java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri 0088:test02 -rs iso6523-actorid-upis -d 0088.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='0088:test02', scheme='iso6523-actorid-upis'}] and domain: [0088.iso6523.participants.ecosystem.org]

    NAPTR query: PUTEUP6A7HSJKCCIAOPTTGURPR5JO253IYZGAMRE2MZNUZMIA7JA.iso6523-actorid-upis.0088.iso6523.participants.ecosystem.org
    github-smp.publisher.0088.iso6523.participants.ecosystem.org.   60      IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .


Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri 0088:test02 -rs iso6523-actorid-upis -d 0088.iso6523.participants.ecosystem.org -t NAPTR -o test-uc01b.xml

Response:
The file test-uc01b.xml was created with corresponding capability document retrieved from the 'Github SMP'.


### Test: Use case 1.c

Resolve the DNS records registered in the **top-level domain authoritative DNS server** using the Oasis EBCore party identifier format.
Test DNS resolution:

Command:

    java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:0088:test02 -d 0088.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='urn:oasis:names:tc:ebcore:partyid-type:iso6523:0088:test02', scheme='null'}] and domain: [0088.iso6523.participants.ecosystem.org]

    NAPTR query: AEY47QMI5YC46ORUMD54WGE6NYT42B57TXXSF3H63OP7FL7ANR3A.0088.iso6523.participants.ecosystem.org
    github-smp.publisher.0088.iso6523.participants.ecosystem.org.   38      IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .


Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:0088:test02 -d 0088.iso6523.participants.ecosystem.org -t NAPTR -o test-uc01c.xml

Response:
The file test-uc01c.xml was created with corresponding capability document retrieved from the 'Github SMP'.


### Test: Use case 2

Resolve the DNS records registered in the **"NS Delegated" DNS server** using the Peppol party identifier format.
 
Test DNS resolution:

Command:

    java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri 0195:test01 -rs iso6523-actorid-upis -d 0195.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='0195:test01', scheme='iso6523-actorid-upis'}] and domain: [0195.iso6523.participants.ecosystem.org]

    NAPTR query: RYATFMWWQQHEY4T7VPPCXY7Z36T2FOL6QYXRGYF3V7S5LGJUAH2Q.iso6523-actorid-upis.0195.iso6523.participants.ecosystem.org
    RYATFMWWQQHEY4T7VPPCXY7Z36T2FOL6QYXRGYF3V7S5LGJUAH2Q.iso6523-actorid-upis.0195.iso6523.participants.ecosystem.org.      86400   IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .


Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri 0195:test01 -rs iso6523-actorid-upis -d 0195.iso6523.participants.ecosystem.org -t NAPTR -o test-uc02.xml

Response:
The file test-uc02.xml was created with corresponding capability document retrieved from the 'Github SMP'.


### Test: Use case 2.a

Resolve the DNS records registered in the **"NS Delegated" DNS server** using the OASIS EBCore party identifier format.
Test DNS resolution:

Command:

    java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:0195:test01 -d 0195.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='test01', scheme='urn:oasis:names:tc:ebcore:partyid-type:iso6523:0195'}] and domain: [0195.iso6523.participants.ecosystem.org]

    NAPTR query: SW7FCYYKJI7YP27JILCJRNPIODTJYYO2DH3CAVWPSNPX3GJKGNZA.0195.iso6523.participants.ecosystem.org
    SW7FCYYKJI7YP27JILCJRNPIODTJYYO2DH3CAVWPSNPX3GJKGNZA.0195.iso6523.participants.ecosystem.org.   86400   IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .


Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:0195:test01 -d 0195.iso6523.participants.ecosystem.org -t NAPTR -o test-uc02a.xml

Response:
The file test-uc02a.xml was created with corresponding capability document retrieved from the 'Github SMP'.

### Test: Use case 2.b

Resolve the DNS records registered in the **"NS Delegated" DNS server** using the Peppol party identifier format.
Test DNS resolution:

Command:

    java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri 0195:test02 -rs iso6523-actorid-upis -d 0195.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='0195:test02', scheme='iso6523-actorid-upis'}] and domain: [0195.iso6523.participants.ecosystem.org]

    NAPTR query: SQOK3QIXO5V26IRVUCVR2GJVZNVR5AFNB57ABHELYAI72ZIQ7ITQ.iso6523-actorid-upis.0195.iso6523.participants.ecosystem.org
    github-smp.publisher.0195.iso6523.participants.ecosystem.org.   86400   IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .



Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri 0195:test02 -rs iso6523-actorid-upis -d 0195.iso6523.participants.ecosystem.org -t NAPTR -o test-uc02b.xml

Response:
The file test-uc02b.xml was created with corresponding capability document retrieved from the 'Github SMP'.


### Test: Use case 2.c

Resolve the DNS records registered in the **"NS Delegated" DNS server** using the OASIS EBCore party identifier format.
Test DNS resolution:

Command:

    java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:0195:test02  -d 0195.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='urn:oasis:names:tc:ebcore:partyid-type:iso6523:0195:test02', scheme='null'}] and domain: [0195.iso6523.participants.ecosystem.org]

    NAPTR query: SWDXXVXUUTFABXJAAWCM4EUDZJUMNLUWJ3HZZY7QARWGRKA7Q4HQ.0195.iso6523.participants.ecosystem.org
    github-smp.publisher.0195.iso6523.participants.ecosystem.org.   85880   IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .

Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:0195:test02 -d 0195.iso6523.participants.ecosystem.org -t NAPTR -o test-uc02c.xml

Response:
The file test-uc02c.xml was created with corresponding capability document retrieved from the 'Github SMP'.


### Test: Use case 3

Resolve the DNS records registered in the **"DNAME Delegated" DNS server** using the Peppol party identifier format.

Test DNS resolution:

Command:

    java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri 9914:test01 -rs iso6523-actorid-upis -d 9914.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='9914:test01', scheme='iso6523-actorid-upis'}] and domain: [9914.iso6523.participants.ecosystem.org]

    NAPTR query: GBDLL6QCELDM5JLQCWGP5CONIVXDP6BV2NZWWWI6BY5SFMNUYN7A.iso6523-actorid-upis.9914.iso6523.participants.ecosystem.org
    GBDLL6QCELDM5JLQCWGP5CONIVXDP6BV2NZWWWI6BY5SFMNUYN7A.iso6523-actorid-upis.9914.iso6523.g2b.at.  86400   IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .

Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri 9914:test01 -rs iso6523-actorid-upis -d 9914.iso6523.participants.ecosystem.org -t NAPTR -o test-uc03.xml

Response:
The file test-uc03.xml was created with corresponding capability document retrieved from the 'Github SMP'.

### Test: Use case 3.a

Resolve the DNS records registered in the **"DNAME Delegated" DNS server** using the OASIS EBCore party identifier format.
Test DNS resolution:

Command:

    java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:9914:test01 -d 9914.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='urn:oasis:names:tc:ebcore:partyid-type:iso6523:9914:test01', scheme='null'}] and domain: [9914.iso6523.participants.ecosystem.org]

    NAPTR query: SXURSAE2VXDDT4KMND6H3CLAIEYULN5JQ6RFNJIG374NJARGSF6Q.9914.iso6523.participants.ecosystem.org
    SXURSAE2VXDDT4KMND6H3CLAIEYULN5JQ6RFNJIG374NJARGSF6Q.9914.iso6523.g2b.at.       86400   IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .

Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:9914:test01 -d 9914.iso6523.participants.ecosystem.org -t NAPTR -o test-uc03a.xml

Response:
The file test-uc03a.xml was created with corresponding capability document retrieved from the 'Github SMP'.

### Test: Use case 3.b

Resolve the DNS records registered in the **"DNAME Delegated" DNS server** using the Peppol party identifier format.
Test DNS resolution:

Command:

    java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri 9914:test02 -rs iso6523-actorid-upis -d 9914.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='9914:test02', scheme='iso6523-actorid-upis'}] and domain: [9914.iso6523.participants.ecosystem.org]

    NAPTR query: 57PSJISUOE7GR4UXE2M7IBKNLQV5CZS55QOIHAH3G67JVDOKTY3A.iso6523-actorid-upis.9914.iso6523.participants.ecosystem.org
    github-smp.publisher.9914.iso6523.g2b.at.       86400   IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .

Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri 9914:test02 -rs iso6523-actorid-upis -d 9914.iso6523.participants.ecosystem.org -t NAPTR -o test-uc03b.xml

Response:
The file test-uc03b.xml was created with corresponding capability document retrieved from the 'Github SMP'.

### Test: Use case 3.c

Resolve the DNS records registered in the **"DNAME Delegated" DNS server** using the OASIS EBCore party identifier format.
Test DNS resolution:

Command:

    java -Ddns.server=localhost:54 -jar ddc.jar -dns -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:9914:test02  -d 9914.iso6523.participants.ecosystem.org -t NAPTR

Response:

    Resolving DNS for participant: [ParticipantIdentifier{identifier='urn:oasis:names:tc:ebcore:partyid-type:iso6523:9914:test02', scheme='null'}] and domain: [9914.iso6523.participants.ecosystem.org]

    NAPTR query: EMAOWJNPC73TKW737YRUFA6X2XFP5N6NBJFGWLFKY74CR55IIF5A.9914.iso6523.participants.ecosystem.org
    github-smp.publisher.9914.iso6523.g2b.at.       86381   IN      NAPTR   100 10 "U" "Meta:SMP" "!.*!https://raw.githubusercontent.com/ec-edelivery/dynamic-discovery-federated-infrastructure/refs/heads/main/uc02-dynamic-discovery-client/smp-resources/!" .

Fetching the capability document:
Command (note: the ddc parameter -dns was changed to -get and the -o parameter was added to define the output file):

    java -Ddns.server=localhost:54 -jar ddc.jar -get -ri urn:oasis:names:tc:ebcore:partyid-type:iso6523:9914:test02 -d 9914.iso6523.participants.ecosystem.org -t NAPTR -o test-uc03c.xml

Response:
The file test-uc03c.xml was created with corresponding capability document retrieved from the 'Github SMP'.

## Conclusion

he PoC environment demonstrates the setup of a federated DNS service with the top-level domain ecosystem.org. It showcases various subdomain delegation methods, including standard NS delegation and DNAME redirection.

The PoC tests confirm that already some of the existing Dynamic Discovery Client (DDC) can resolve DNS NAPTR records in proposed federated DNS environment. In the test, we used the Peppol participant identifier and the OASIS EBCore party identifier format.

