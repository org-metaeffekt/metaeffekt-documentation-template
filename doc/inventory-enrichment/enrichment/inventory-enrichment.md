> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > Inventory Enrichment

# Inventory Enrichment

The enrichment process uses a pipeline model to represent the individual steps involved. Each step takes an inventory as
input and outputs a modified inventory.

This pipeline can be constructed programmatically using Java classes or using the plugin in a Maven POM. Both will be
shown in the following documents.

## Sub-Chapters

And about all Inventory Enrichment steps with their configuration parameters:

- [Inventory Enrichment Steps](steps.md)
- [Superclasses](java-super-classes.md) (useful background information for understanding the process)

Learn more about how to build a pipeline yourself here:

- [Java process](java.md)
- [Maven POM](maven.md)

## Overview / Data flow

As mentioned above, an `InventoryEnrichmentPipeline` is constructed from multiple `InventoryEnricher` instances. They
each have an `InventoryEnricherConfiguration` that can be used to pass additional parameters from the outside. Learn
more about these classes in [Superclasses](java-super-classes.md).

The pipeline takes a source inventory (file/instance) that it passes through all the enricher instances. The pipeline
can be configured such that it saves the intermediate steps into a local directory. Out comes an inventory that has
passed through all steps, which is written to some output file.

The enrichment steps can require a certain index to be present. For an overview over all steps that require indexes to
be present, see [this document](../dependants.svg).

![Inventory Enrichment Process Overview](inventory-enrichment-process-overview.drawio.svg)

## Pipeline logs

The logs of the enrichment process are quite interesting actually.

```java
-------------------< Inventory Enrichment Pipeline >--------------------
Enriching inventory with [1 artifact] and [0 vulnerabilities]
Enrichment order:
 1. CPE URI derivation
 2. MSRC Vulnerabilities by Products
 3. NVD CVE from CPE

-------------------------< CPE URI derivation >-------------------------
Enriching inventory with [1 artifact] and [0 vulnerabilities]
Configuration:
  maxCorrelatedCpePerArtifact: 2147483647
Starting up to [15] threads at once, [1] to run in total. Delay of [0] between each thread and [0] between each batch
Started [1 / 1] threads [100 %]
Deriving CPE URIs for artifact [1 / 1] [cups-filesystem-1.7.5: cups-filesystem 1.7.5]
All threads finished
----------------------< Done: CPE URI derivation >----------------------


------------------< MSRC Vulnerabilities by Products >------------------
Enriching inventory with [1 artifact] and [0 vulnerabilities]
Added [1] vulnerability to inventory: [ADV220005]
Added [320] vulnerabilities to inventory: [CVE-2022-44678, CVE-2022-41047, CVE-2022-44677, CVE-2022-41048, CVE-2022-44676, CVE-2022-41045, CVE-2022-44675, CVE-2023-21527, CVE-2022-41049, CVE-2022-44679, ...
Artifact [cups-filesystem-1.7.5] with product [11929] ([11929]) and [1] KB has [320 vulnerabilities] [1 advisories] [331 fixed by KB] from [652 & 649 -> 652] vulnerabilities/advisories
---------------< Done: MSRC Vulnerabilities by Products >---------------


--------------------------< NVD CVE from CPE >--------------------------
Enriching inventory with [1 artifact] and [321 vulnerabilities]
Configuration:
  maxCorrelatedVulnerabilitiesPerArtifact: 2147483647
Starting up to [15] threads at once, [1] to run in total. Delay of [0] between each thread and [0] between each batch
Started [1 / 1] threads [100 %]
Collecting CVE from CPE for artifact [1 / 1] [cups-filesystem-1.7.5: cups-filesystem 1.7.5]
Removed [0] matched vulnerabilities fixed by patches.
Added [2] vulnerabilities to inventory: [CVE-2015-1158, CVE-2015-1159]
All threads finished
-----------------------< Done: NVD CVE from CPE >-----------------------

All enrichment steps have been applied successfully:
 1. CPE URI derivation  . . . . . . . . . . . . . . . . . . [  2s 59ms]
 2. MSRC Vulnerabilities by Products  . . . . . . . . . . . [ 1s 928ms]
 3. NVD CVE from CPE  . . . . . . . . . . . . . . . . . . . [    197ms]
----------------< Done: Inventory Enrichment Pipeline >-----------------
```

Almost more interesting than that is the log when the process failed. It shows exactly where the error happened and
what resume-at ID to use if you want to retry from that step only. More information on that can be found in the Java
and Maven POM examples.

```java
-------------------< Inventory Enrichment Pipeline >--------------------
Enriching inventory with [1 artifact] and [0 vulnerabilities]
Enrichment order:
 1. CPE URI derivation
 2. MSRC Vulnerabilities by Products
 3. NVD CVE from CPE

-------------------------< CPE URI derivation >-------------------------
Enriching inventory with [1 artifact] and [0 vulnerabilities]
Configuration:
  maxCorrelatedCpePerArtifact: 2147483647
Starting up to [15] threads at once, [1] to run in total. Delay of [0] between each thread and [0] between each batch
Started [1 / 1] threads [100 %]
Deriving CPE URIs for artifact [1 / 1] [cups-filesystem-1.7.5: cups-filesystem 1.7.5]
All threads finished
----------------------< Done: CPE URI derivation >----------------------


------------------< MSRC Vulnerabilities by Products >------------------
Enriching inventory with [1 artifact] and [0 vulnerabilities]
Added [1] vulnerability to inventory: [ADV220005]
Added [320] vulnerabilities to inventory: [CVE-2022-44678, CVE-2022-41047, CVE-2022-44677, CVE-2022-41048, CVE-2022-44676, CVE-2022-41045, CVE-2022-44675, CVE-2023-21527, CVE-2022-41049,
Artifact [cups-filesystem-1.7.5] with product [11929] ([11929]) and [1] KB has [320 vulnerabilities] [1 advisories] [331 fixed by KB] from [652 & 649 -> 652] vulnerabilities/advisories
Failed to enrich inventory on step [MSRC Vulnerabilities by Products], see stack trace below for more information.
--------------< FAILED: MSRC Vulnerabilities by Products >--------------

To resume from failed step, use id [msrc-vulnerabilities-by-product-enrichment]
 1. CPE URI derivation  . . . . . . . . . . . . . . . . . . [ 1s 771ms]
Failed at:
 2. MSRC Vulnerabilities by Products  . . . . . . . . . . . [ 1s 801ms]
 3. NVD CVE from CPE  . . . . . . . . . . . . . . . . . . . [      0ms]

java.lang.RuntimeException: Failed to enrich inventory on step MSRC Vulnerabilities by Products
    ... stack trace ...
```
