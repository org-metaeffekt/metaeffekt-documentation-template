> Vulnerability Monitoring

# Vulnerability Monitoring: Inventory Enrichment

> ! **The documentation here references the versions 1.x of the vulnerability enrichment pipeline.**
> As of 2023-02-02, a version 3.0 is released, meaning this documentation is vastly out of date.
> Use it with caution.

An inventory generated by one of the extrators can be processed by the inventory enrichment pipeline in order to derive
publicly available vulnerability information. This enriched inventory can then be used to generate a Vulnerability
Assessment Dashboard (single page HTML) and Vulnerability Report (PDF).

In order to reduce the amount of requests that are made during runtime to increase performance and to prevent tracing of
activities by data providers or via networks tracking, these data sources are first fully downloaded into a local
directory and then indexed into a data structure.

To improve performance and prevent tracing of activities by data providers, data sources are fully downloaded into a
local directory. Then, they are indexed into a data structure to reduce the number of requests made during runtime.

This process is split into multiple parts, that are each described in their own document:

### Data Sources Mirroring

Learn how to create a data mirror for the data sources that are used by the inventory enrichment process.  
View the overview page of the [**Data Sources Mirroring**](mirror/mirror-overview.md) first.

- [List of individual downloads](mirror/download.md)
- [List of individual indexes](mirror/index.md)

### Inventory Enrichment

This collection of pages explains how to set up the process for yourself.  
View the overview page of the [**Inventory Enrichment**](enrichment/inventory-enrichment.md) first.

- [List of Inventory Enrichment Steps](enrichment/steps.md)
- Examples:
    - [Maven POM](enrichment/maven.md)
    - [Java process](enrichment/java.md)
- [Artifact Correlation YAML](enrichment/artifact-correlation.md)
- [Vulnerability Assessment (Status) files](enrichment/vulnerability-status-gen-3.md)
- _[DEPRECATED: Vulnerability Assessment (Status) files](enrichment/vulnerability-status.md)_
- [Vulnerability Keywords files](enrichment/vulnerability-keywords.md)
- [Vulnerability Filter format](enrichment/vulnerability-filter-format.md)
- [Dashboard Detail Levels format](enrichment/vad-detail-levels.md)
- [Custom Vulnerability Data Sources](enrichment/custom-vulnerabilities.md)

### Data Sources Explained

- [MSRC](msrc/understanding-data.md)
- [GHSA](ghsa/understanding-data.md)
- [EOL Date](eol-date/understanding-data.md)

### Other chapters:

- [Inventory Vulnerability Status differ](enrichment/vulnerability-status-differ.md)
- [Architecture: Superclasses](enrichment/java-super-classes.md) (useful background information for understanding
  the process)
- [Inventory CPE data and effective CPE](enrichment/parsing-effective-cpe.md)
- [Version comparator](other/version-comparator.md)

## Overview graphs

This image provides a high-level overview over the process:

![Process overview](inventory-enrichment-overview.svg)

This image provides a list of all classes that are involved and their dependencies/data flow. Open the image in a new
tab to see all details.

![List of related classes and data flow](dependants.svg)
