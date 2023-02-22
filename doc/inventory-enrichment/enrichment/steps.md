> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Inventory Enrichment](inventory-enrichment.md) >
> Inventory Enrichment Steps

# Inventory Enrichment Steps

As some steps require other steps to be run before them, there is a certain default order the following steps should be
executed in:

- **Step 1**: find vulnerability identifiers  
  `artifactYamlEnrichment`, `cpeDerivationEnrichment`, `msVulnerabilitiesByProductEnrichment`,
  `nvdMatchCveFromCpeEnrichment`, `customVulnerabilitiesFromCpeEnrichment`

- **Step 2**: fill vulnerability meta data for matched identifiers  
  `nvdCveFillDetailsEnrichment`, `customVulnerabilitiesFillDetailsEnrichment`, `msrcAdvisorFillDetailsEnrichment`

- **Step 3**: add status/keyword data  
  `vulnerabilityStatusEnrichment`, `vulnerabilityKeywordsEnrichment`

- **Step 4**: fill vulnerability meta data and add advisory data if available  
  `nvdCveFillDetailsEnrichment`, `customVulnerabilitiesFillDetailsEnrichment`, `msrcAdvisorFillDetailsEnrichment`,
  `certFrAdvisorEnrichment`, `certSeiAdvisorEnrichment`

- **Step 5**: use data to create VAD
  `vulnerabilityAssessmentDashboardEnrichment`

- **Other**: steps that do not belong into the main enrichment process  
  `advisorPeriodicEnrichment`

Open the following image in a new tab to see more details about the requirements between the different steps:

![Enrichment steps order](inventory-enrichment-steps-order.svg)
