# Vulnerability Monitoring: Inventory Enrichment

An inventory generated by one of the extrators can be processed by the inventory enrichment pipeline in order to derive
publicly available vulnerability information. This enriched inventory can then be used to generate a Vulnerability
Assessment Dashboard (single page HTML) and Vulnerability Report (PDF).

Data sources include:

- [NVD](https://nvd.nist.gov/vuln)
  - Vulnerability (CVE)
  - Vendor/product (CPE)
- [CERT-FR](https://www.cert.ssi.gouv.fr/)
  - Advisories
- [CERT-SEI](https://www.sei.cmu.edu/about/divisions/cert/)
  - Advisories
- [MSRC](https://msrc.microsoft.com/update-guide/vulnerability)
  - Advisories
  - Microsoft products
  - Knowledge Base (Security Updates)

In order to reduce the amount of requests that are made during runtime to increase performance and to prevent tracing of
activities by data providers or via networks tracking, these data sources are first downloaded and then indexed into a
local data structure.

![Process overview](inventory-enrichment-overview.svg)