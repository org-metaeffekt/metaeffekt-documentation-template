# metaeffekt-documentation-template

## Overview

![Alt](doc/overview.png)

## Current Scope
- illustrate extraction from containers
- illustrate extraction from a POM
- generate vulnerability dashboard based on the extracted inventories
  
## Future Scope
- illustrate extraction from NodeJS
- illustrate local source scan for licenses
- include configuration for creating local vulnerability mirror
- generate CycloneDx BOM from inventories
- ingest DependencyTrack results

## Build Instructions

    mvn clean install -Pextract,advise,document -Dinput.database=<path-to-vulnerability-mirror>

With container enabled (currently disabled):
    
    mvn clean install -Pextract,advise,document -Dimage.repo=debian -Dimage.tag=latest

The actions Extract, advise and document have been split using profiles to
be used separately from the command line. Extract is a prerequisite to advise and document. Advise is prerequisite for document.

## DISCLAIMER
Currently, the provided inventory does only contain minimal information. 
We promise to add more data to better illustrate the use cases.
