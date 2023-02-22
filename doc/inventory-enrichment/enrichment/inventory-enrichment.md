> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > Inventory Enrichment

# Inventory Enrichment

The enrichment process uses a pipeline model to represent the individual steps involved. Each step takes an inventory as
input and outputs a modified inventory.

This pipeline can be constructed programmatically using Java classes or using the plugin in a Maven POM. Both will be
shown in the following documents.

## Sub-Chapters

Learn more about how to build a pipeline yourself here:

- [Java process](java.md)
- [Maven POM](maven.md)

And about all Inventory Enrichment steps with their configuration parameters:

- [Inventory Enrichment Steps](steps.md)

## Overview / Data flow

As mentioned above, an `InventoryEnrichmentPipeline` is constructed from multiple `InventoryEnricher` instances. They
each have an `InventoryEnricherConfiguration` that can be used to pass additional parameters from the outside.

The pipeline takes a source inventory (file/instance) that it passes through all the enricher instances. The pipeline
can be configured such that it saves the intermediate steps into a local directory. Out comes an inventory that has
passed through all steps, which is written to some output file.

The enrichment steps can require a certain index to be present. For an overview over all steps that require indexes to
be present, see [this document](../dependants.svg).

![Inventory Enrichment Process Overview](inventory-enrichment-process-overview.drawio.svg)
