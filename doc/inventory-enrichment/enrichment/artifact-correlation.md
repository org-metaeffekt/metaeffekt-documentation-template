# Vulnerability Assessment (Correlation)

> :warning: This document is still WIP and may contain outdated/useless information without context  
> TODO

## Initial Inventory enrichment

1. Seperate Inventories into directories
2. Assert that vulnerability Mirror exists
    1. in VulnerabilityEnrichmentTest beforeAll set update true
    2. run any Method in Class
3. copy Inventory path
4. paste into externalInventory variable
5. run enrichAndCreateDashboardFromOtherTest

## Correlation loop

1. Create yaml file in same directory: <inventory name> - data.yaml
2. open yaml file in Intellij
    1. if json schema not yet defined: click bottom right No JSON schema → edit schema mappings → copy and insert path
       for artifact-data.json
3. run ArtifactYamlUtilities main method

# Writing a correlation file (+ best practices)

Using the ArtifactYamlUtilities class in the artifact analysis project, launch the main method and enter the path to the
enriched inventory. Navigate the inventory using the commands listed in the command line.

### Initial state

An artifact can be in multiple different states:

- No matched CPE URIs in the Derived CPE URIs field
- Matched CPE URIs in the Derived CPE URIs field

If CPE URIs have been matched, use the built in features of the CLI-tool and search the internet for hints that the
matched entry is correct/incorrect.
If no CPE URIs have been matched or the ones matched were incorrectly added, search the internet for (vulnerability)
information on the artifact.

### **Creating the entry**

Once the research is completed and at least one modification to the artifact is required OR at least a CPE URI has been
correctly matched, an entry in the YAML file has to be created. To assist you with this, the CLI-tool can generate an
entry for you: Enter ca and the raw entry will be copied to your clipboard. This will look something like this:

\# Id:               reactor-netty-0.8.8.RELEASE.jar

\# Component:        Reactor Project

\# Group Id:         io.projectreactor.netty

\# Version:          0.8.8.RELEASE

\# Derived CPE URIs: cpe:/a:pivotal:reactor\_netty

\# reason:           cpe:/a:pivotal:reactor\_netty -->

\- affects:

`    `Id: reactor-netty-\*.jar

`  `append:

`    `Inapplicable CPE URIs: cpe:/a:pivotal:reactor\_netty

This will include the artifact information in a formatted comment header and an affects and append section.

When adding/removing CPEs, only the Inapplicable CPE URIs and Additional CPE URIs attributes should be used. CPE URIs
(with sometimes cpe:/a:none:none has been used in the past, but has been considered potentially dangerous, as it will
lead to the artifact never matching with any new/other CPEs in the future. It is better to be notified of too many
vulnerabilities than too few.
This means, all inapplicable CPE URIs should be listed in a comma-separated list under Inapplicable CPE URIs and
additional ones under Additional CPE URIs.

### **Correctly derived CPE**

When CPEs have been derived correctly by the system, an entry with the CPE should be created under Additional CPE URIs.
This is so that when the derivation algorithm changes in the future, the CPE does not disappear from the derived list.

Example:

\# Id:               slf4j-api-1.7.26.jar

\# Component:        SLF4J

\# Group Id:         org.slf4j

\# Version:          1.7.26

\# Derived CPE URIs: cpe:/a:qos:slf4j

\- affects:

`    `Id: slf4j-api-\*.jar

`  `append:

`    `Additional CPE URIs: cpe:/a:qos:slf4j

### **Reasoning chain**

As seen above, the automatically generated entry contains a reason tag: # reason: cpe:/a:pivotal:reactor\_netty -->
This is so that when the entry is visited in the future, the reason behind the modifications can be understood. The best
practice for this is:

- one entry per line (one CPE/Artifact/…)
- a reasoning chain connected by --> arrows with links/text in between

An example:

\#
reason: https://people.apache.org/~germuska/struts-taglib/docs/apidocs/org/apache/struts/taglib/html/package-summary.html -->
The "struts-html" tag library contains JSP custom tags useful in creating dynamic HTML user interfaces, including input
forms.

\# cpe:/a:taglib:taglib --> https://taglib.org/ --> TagLib is a library for reading and editing the meta-data of several
popular audio formats

### **Follow-up entries**

Multiple entries can be chained together to form more of a logic than a simple entry can. See this example:

\- affects:

`    `- Component: Spring Security\*

`    `- Id: spring-security-\*.jar

`  `append:

`    `Additional CPE URIs: cpe:/a:pivotal\_software:spring\_security, cpe:/a:vmware:spring\_security, cpe:/a:vmware:
springsource\_spring\_security

\- affects:

`    `Id: spring-security-oauth\*.jar

`  `append:

`    `Additional CPE URIs: cpe:/a:pivotal\_software:spring\_security\_oauth, cpe:/a:pivotal:spring\_security\_oauth

`  `remove:

`    `Additional CPE URIs: cpe:/a:pivotal\_software:spring\_security, cpe:/a:vmware:spring\_security, cpe:/a:vmware:
springsource\_spring\_security

todo

### **Multiple entries in affects**

todo

### **Duplicate entries**

todo; entries with the same CPE information should be merged into one with a list of criteria … see multiple entries in
affects

### **Never-correct entries (github:github and jboss:jboss)**

todo
