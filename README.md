[![Java 11 Build with Maven](https://github.com/org-metaeffekt/metaeffekt-documentation-template/actions/workflows/maven.yml/badge.svg)](https://github.com/org-metaeffekt/metaeffekt-documentation-template/actions/workflows/maven.yml)

# metaeffekt-documentation-template

## Documentation

The documentation has been moved to [metaeffekt-documentation](https://github.com/org-metaeffekt/metaeffekt-documentation/tree/main).

## Overview

![Flowchart showing how the assets and different processes are used to form a Software Annex PDF and a Vulnerability Assessment Dashboard](doc/overview.png)

## Current Scope

- illustrate extraction from containers
- illustrate extraction from a POM
- include configuration for creating local vulnerability mirror
- generate vulnerability dashboard based on the extracted inventories
- generate a software distribution annex containing a bill of materials
- generate a vulnerability report including assessment data.

## Future Scope / Work in Progress

- illustrate extraction from NodeJS
- illustrate local source scan for licenses
- generate CycloneDx SBOM from inventories
- generate inventory from CycloneDx SBOM
- ingest DependencyTrack results
- generate periodic vulnerability report

## Build Instructions

Mirror the vulnerability databases once using the `mirror-download` profile:

    mvn clean install -Pmirror-download,mirror-index

To successfully mirror the database an API-Key might be necessary if not provided already.
Either create a new top-level directory `.maven` containing a `maven.config` file which should contain the following:

    -Dnvd.apikey=<api-key>

Or append the flag directly via CLI:

    mvn clean install -Pmirror-download,mirror-index -Dnvd.apikey=<api-key>

This process may take around 40 minutes. The process will create a local mirror of public vulnerability data in the `.database`
folder. Rerun the process to update the data regularly.


Run the extraction and advisories/documents generation using the `extract`, `advise`, `document` profiles:

    mvn clean install -Pextract,advise,document,report

The profile `advise` is split into two separate profiles `advise-correlate` and `advise-vulnerability`, which are
activated by default. To disable one of these, use `-P-advice-correlate` or `-P-advice-vulnerability`. This allows for
splitting the advise process into two separate steps, see [advisors/pom.xml (~line 141)](advisors/pom.xml) in addition
to the commands below for more details:

    mvn clean install -Padvise,-advise-vulnerability
    mvn       install -Padvise,-advise-correlate,document,report

The profiles extract, advise, document and report have been split using profiles to be used separately from the command
line.
Profile `extract` is a prerequisite to `advise` and `document`.
Profile `advise` is prerequisite for `report`.

With container enabled (currently disabled):

    mvn clean install -Pextract,document -Dimage.repo=debian -Dimage.tag=latest

The container enabled process requires that docker daemon is running and the container of interest was already pulled.

## DISCLAIMER

Currently, the provided inventory does only contain minimal information. We promise to add more data to better
illustrate the use cases.
