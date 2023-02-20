> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > Mirror

# Data sources mirror overview

The general mirroring process description can be found in this document, the individual steps in these documents:

- [download.md](download.md)
- [index.md](index.md)

The purpose of the data mirror is to download data (JSON, XML, ...) from a variety of sources into a local directory and
create an index using Lucene Index from it. The index makes it easy to quickly search for data when it's needed during
the enrichment process.

The data is stored in a base directory, divided into two subdirectories named `download` and `index`. When initiating or
accessing a download/index, only the base directory needs to be defined as the normalized subdirectories are
automatically inferred and created.

This diagram shows the data flow in between the different Mirror phases:

![mirror overview process image](mirror-documentation-overview.svg)

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
    - Knowledge Base (KB/Security Updates)
