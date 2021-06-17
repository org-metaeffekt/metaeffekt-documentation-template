# metaeffekt-documentation-template

## Overview

![Alt](doc/overview.png)

## Current Scope
- illustrate extraction from containers
- illustrate extraction from a POM
  
## Future Scope
- illustrate extraction from NodeJS
- illustrate local source scan for licenses
- generate vulnerability dashboard for produces inventories
- generate CycloneDx BOM from inventories
- ingest DependencyTrack results

## Build Instructions

    mvn clean install -P extraction -P documentation

Extraction and documentation have been split in separate profiles to
be used separately. Extraction is a pre-requisite to documentation

## DISCLAIMER
Currently, the provided inventory is empty. We promise to add some example
data to better illustrate the use cases.
