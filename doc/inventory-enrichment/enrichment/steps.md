> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Inventory Enrichment](inventory-enrichment.md) >
> Inventory Enrichment Steps

# Inventory Enrichment Steps

As some steps require other steps to be run before them, there is a certain default order the following steps should be
executed in:

- **Step 1**: find vulnerability identifiers
    - [`artifactYamlEnrichment`](#artifact-correlation-yaml)
    - [`cpeDerivationEnrichment`](#cpe-derivation)
    - [`msVulnerabilitiesByProductEnrichment`](#msrc-vulnerabilities-from-ms-products)
    - [`nvdMatchCveFromCpeEnrichment`](#nvd-cve-from-cpe)
    - [`customVulnerabilitiesFromCpeEnrichment`](#custom-vulnerabilities-from-cpe)

- **Step 2**: fill vulnerability meta data for matched identifiers
    - [`nvdCveFillDetailsEnrichment`](#nvd-cve-details-filling)
    - [`customVulnerabilitiesFillDetailsEnrichment`](#custom-vulnerability-details-filling)
    - [`msrcAdvisorFillDetailsEnrichment`](#msrc-advisor-details-filling)

- **Step 3**: add status/keyword data
    - [`vulnerabilityStatusEnrichment`]()
    - [`vulnerabilityKeywordsEnrichment`]()

- **Step 4**: fill vulnerability meta data and add advisory data if available
    - [`nvdCveFillDetailsEnrichment`](#nvd-cve-details-filling)
    - [`customVulnerabilitiesFillDetailsEnrichment`](#custom-vulnerability-details-filling)
    - [`msrcAdvisorFillDetailsEnrichment`](#msrc-advisor-details-filling)
    - [`certFrAdvisorEnrichment`](#cert-fr-advisors-details-filling)
    - [`certSeiAdvisorEnrichment`](#cert-sei-advisors-details-filling)

- **Step 5**: use data to create VAD
    - [`vulnerabilityAssessmentDashboardEnrichment`](#vulnerability-assessment-dashboard--vad-)

- **Other**: steps that do not belong into the main enrichment process
    - [`advisorPeriodicEnrichment`](#advisor-periodic)

Open the following image in a new tab to see more details about the requirements between the different steps:

![Enrichment steps order](inventory-enrichment-steps-order.svg)

The titles for the individual steps below are build from: `Step Name → Class Name / Maven POM config parameter`.

## Step 1: find vulnerability identifiers

### Artifact Correlation YAML

→ `ArtifactYamlEnrichment` / `artifactYamlEnrichment`

#### User description:  
This step is mainly used to perform the first manual step of the vulnerability assessment process. It allows for
overwriting the findings from the following automatic steps by appending and subtracting information from any field on
artifacts in an inventory.

It uses YAML files in the [Artifact Correlation YAML format](example-data/artifact-data.json) to find matching artifacts
and append some data to them.

An example for how we do this:  
A file consists of a list of entries, each one having a header comment block in front of it with the original artifact
attributes and a reason, why this correlation has been picked. After that: the actual entry with at least an `affects`
and an `append`/`remove` section. In all sections, artifact attributes can be listed.

```yaml
# Id:               org.eclipse.jetty.continuation_9.4.18.v20190429.jar
# Component:        Eclipse Jetty Continuation
# Version:          9.4.18.v20190429
# Derived CPE URIs: cpe:/a:eclipse:jetty, cpe:/a:jetty:jetty
# reason:           cpe:/a:jetty:jetty --> Additional Jetty repositories not covered by the Eclipse Foundation IP policy
#                   cpe:/a:mortbay:jetty --> https://en.wikipedia.org/wiki/Jetty_(web_server)#History
#                   cpe:/a:mortbay_jetty:jetty --> https://en.wikipedia.org/wiki/Jetty_(web_server)#History
- affects:
    - Component: Eclipse Jetty*
    - Id: jetty*.jar
  ignores:
    Id: jetty-server*.jar
  append:
    Inapplicable CPE URIs: cpe:/a:jetty:jetty_http_server
    Additional CPE URIs: cpe:/a:eclipse:jetty, cpe:/a:mortbay:jetty, cpe:/a:mortbay_jetty:jetty, cpe:/a:jetty:jetty
```

For more details on how-to and to see our philosophy, view
[Vulnerability Assessment (Correlation)](artifact-correlation.md).

#### Technical description:  
For each YAML file specified:

1. Parse all `YamlDataEntry` from the file
2. For each entry:
    1. Find the artifacts affected by the entry by using `YamlDataEntry#affects()`
    2. Apply the entry to the artifact by appending/setting values in or removing fields by using
       `YamlDataEntry#apply()`

#### Affected attributes

- `Artifact Inventory`
  - read/write :mag_right: :memo:
    - any attribute

### CPE Derivation

→ `CpeDerivationEnrichment` / `cpeDerivationEnrichment`

### MSRC Vulnerabilities from MS Products

→ `MsrcVulnerabilitiesByProductEnrichment` / `msVulnerabilitiesByProductEnrichment`

### NVD CVE from CPE

→ `NvdVulnerabilitiesFromCpeEnrichment` / `nvdMatchCveFromCpeEnrichment`

### Custom Vulnerabilities from CPE

→ `CustomVulnerabilitiesFromCpeEnrichment` / `customVulnerabilitiesFromCpeEnrichment`

## Step 2: fill vulnerability meta data for matched identifiers

### NVD CVE details filling

→ `NvdCveDetailsFillingEnrichment` / `nvdCveFillDetailsEnrichment`

### Custom Vulnerability details filling

→ `CustomVulnerabilitiesDetailsFillingEnrichment` / `customVulnerabilitiesFillDetailsEnrichment`

### MSRC Advisor details filling

→ `MsrcAdvisorFillDetailsEnrichment` / `msrcAdvisorFillDetailsEnrichment`

## Step 3: add status/keyword data

### Vulnerability Status

→ `VulnerabilityStatusEnrichment` / `vulnerabilityStatusEnrichment`

### Vulnerability Keywords

→ `VulnerabilityKeywordsEnrichment` / `vulnerabilityKeywordsEnrichment`

## Step 4: fill vulnerability meta data and add advisory data if available

### CERT-FR Advisors details filling

→ `CertFrAdvisorFillDetailsEnrichment` / `certFrAdvisorEnrichment`

### CERT-SEI Advisors details filling

→ `CertSeiAdvisorFillDetailsEnrichment` / `certSeiAdvisorEnrichment`

## Step 5: use data to create VAD

### Vulnerability Assessment Dashboard (VAD)

→ `VulnerabilityAssessmentDashboard` / `vulnerabilityAssessmentDashboardEnrichment`

## Other

### Advisor Periodic

→ `AdvisorPeriodicEnrichment` / `advisorPeriodicEnrichment`
