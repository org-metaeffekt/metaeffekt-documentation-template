> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Mirror](mirror-overview.md) > Index

# Index

This chapter explains what information can be extracted from the [downloads](download.md) using the index processes. For
an overview on the dependencies between downloads and indexes, see [this overview graph](../dependants.svg).

* [Index](#index)
    * [Common steps](#common-steps)
    * [List of indexes](#list-of-indexes)
        * NVD API
            * NVD CPE API (CPEs)
            * NVD CPE API (Vendor/Product pairs)
            * NVD CVE API
        * CERT-SEI (advisory data)
        * CERT-FR (advisory data)
        * MSRC Products
        * MSRC Advisors (advisory data)
        * MSRC KB Chains
    * [List of deprecated downloads](#list-of-deprecated-downloads)
        * Legacy NVD CVE/CPE Information
            * CPE Dictionary (CPEs)
            * CPE Dictionary Vendor Product (Vendor/Product pairs)
            * NVD Vulnerabilities (CVE)

## Common steps

Some base information:

- the index created is a Lucene Index. Such an index contains a list of documents, where each document is a Key-Value
  Map. Depending on the index, these maps can contain different data.
- indexes can depend on one or more other downloads or indexes. If an index is attempted to be created or updated while
  dependent structures are not present, the index will be aborted.
- internally, every index is encapsulated within a single class that extends `Index`. The index files are stored in
  `BASE DIR/index/INDEX NAME`.

The indexing process will only be performed if any of the following conditions are met:

- if the index is not present at all
- if the last update time is further back than a specified time
- if any of the dependent downloads have been updated since the last indexing

The different indexers work very different from each other, as the data provided by the remote sources comes in a wide
variety of formats. This is the main structure:

- wait for the directory to be unlocked. Other indexes can lock the directory if they require the directory not to be
  changed. The default timeout for this is 10 minutes.
- lock the directory to prevent other processes to write/read the index information in parallel.
- check whether indexing is required at all using the criteria listed above. If not, abort the process now.
- backup the index in case an exception occurs
- fully clear the index
- create the index:
    - assert that the required downloads and indexes exist
    - create the index documents (different from index to index)
    - if at least one document has been created, write them to the index directory
- if an exception occurred, rollback to the backup. In any case, clear the backup afterwards.
- unlock the directory

## List of indexes

Similar to the downloading processes, the data sources:

- do not share a common format
- do not stay consistent within themselves (change format over time)
- might not even be meant to be machine-readable

This can make it quite challenging to parse the incoming data. Processes have been developed in order to parse these
formats, which is why a consistent notation is required to document these steps: As the Lucene Index works on documents
(Key/Value pairs), each index below will show a table with one/multiple source fields and a target field in the index
that will contain the data from the data sources.

- if split by comma `,` the first available is used
- if split by `&`, both/all are used
- `longest([...])` will use the longest string of the ones in the parameter body
- `if [cond]: [...] else if [cond]: [...] else: [...]` will use the element only if the condition is met
- `[parent] > [child]` is a child accessor, describes from what part of the source document the information comes from
- `"..."` a string
- `...` a field name or text description of content

You can find (more) example files in the [downloads](download.md) section.

---

### NVD API

> :heavy_check_mark: This is the new and preferred way of mirroring the NVD data, as the old data feeds are retired end
> of 2023. Note that you will need an API Key to get reasonable rates from the API.

References:

- API endpoint reference: [Vulnerability API](https://nvd.nist.gov/developers/vulnerabilities)
- API endpoint reference: [Product CPE API](https://nvd.nist.gov/developers/products)
- API functionality overview: [Developers - Start here](https://nvd.nist.gov/developers/start-here)
- API workflow: [API User Workflow](https://nvd.nist.gov/developers/api-workflows)
- Request an API Key: [NVD - API Request](https://nvd.nist.gov/developers/request-an-api-key)

The new NVD API does not provide yearly files, like the old data feeds used to, which is why the format the CPEs are
saved in is already a custom format. To see how the roughly 100 API responses are merged into multiple yearly files, I
highly recommend checking out the [NVD Downloaders](download.md#nvd-api).

---

### NVD CPE API (CPEs) (`cpe-dict` / `nvdCpeIndex`)

All entries from the API have been normalized to match the CPE Dictionary format in the downloader step, which is why
all CPE entries can be parsed in the same way.

All entries have these fields: `cpeName`, `cpeNameId`, `deprecated`, `titles`, `refs`  
`lastModified` and `created` are dropped in this step.

| JSON/XML                     | data structure                                                                                                           |
|:-----------------------------|:-------------------------------------------------------------------------------------------------------------------------|
| `cpeName`                    | `cpe23Uri`                                                                                                               |
| split CPE URI into parts     | `part`, `vendor`, `product`, `version`, `update`, `edition`, `language`, `sw_edition`, `target_sw`, `target_hw`, `other` |
| `cpeNameId`                  | `nvdId`                                                                                                                  |
| `deprecated`                 | `deprecated` (bool)                                                                                                      |
| `titles` > multiple titles   | `titles` (JSON Array)                                                                                                    |
| `references` > multiple refs | `refs` (JSON Array)                                                                                                      |

The NVD ID, titles, references and deprecated information can be queried later, where the titles and refs will be
properly parsed as language-specific titles and reference instances.

---

### NVD CPE API (Vendor/Product pairs) (`cpe-dict-vp` / `nvdCpeVendorProductIndex`)

For all vendors, store a set of their products.  
For all products, store a set of their vendors.

This is used for quickly accessing all vendors/products of a product/vendor. The list of entries is in CSV. The
information is extracted from the NVD CPE API index, making the index required to be completed before this one.

| **index**                                                                      | **data structure** |
|:-------------------------------------------------------------------------------|:-------------------|
| if `vendor → products`: `vp`<br>else if `product → vendors`: `pv`              | `type`             |
| if `vp`: a single vendor<br>else if pv: a CSV list of vendors for the product  | `vendor`           |
| if `pv`: a single product<br>else if vp: a CSV list of products for the vendor | `product`          |

Note that this process is (as of now) 100% identical to the deprecated CPE Dictionary Vendor/Product Index, as the CPE
Dictionary and NVD CPE API interface are the same.

---

### NVD CVE API (`nvd-cve` / `nvdVulnerabilityIndex`)

Every file contained in the download directory is parsed and processed in the same way. An entry in the parsed JSON
Array has these fields: `sourceIdentifier`, `references`, `configurations`, `weaknesses`, `id`, `published`,
`lastModified`, `metrics`, `vulnStatus`, `descriptions`.

| JSON                                                                       | Vulnerability       |
|:---------------------------------------------------------------------------|:--------------------|
| `descriptions` > multiple `lang`/`value` --> find `en` or fallback to any  | description         |
| `published`                                                                | create date         |
| `lastModified`                                                             | update date         |
| `references` > multiple `source` & `url` & `tags`                          | references          |
| `weaknesses` > multiple `description` > multiple `value`                   | cwe                 |
| `metrics` > `cvssMetricV2` > `cvssData` > `vectorString`                   | cvss v2             |
| `metrics` > `cvssMetricV30`, `cvssMetricV31` > `cvssData` > `vectorString` | cvss v3             |
| `configurations` > `nodes` (parse nodes)                                   | vulnerable software |

---

### CERT-SEI (advisory data) (`certsei-advisors` / `certSeiAdvisorIndex`)

The CERT-SEI provides multiple JSON files with one note/advisor per file. To parse the JSON files in the download
directory:

1. Iterate over all JSON files in the directory.
2. Read and parse the JSON contents of each file.
3. Use `CertSeiAdvisorEntry.fromDownloadJson` to map the fields to a `CertSeiAdvisorEntry` object.

| JSON                                                             | CertSeiAdvisorEntry |
|:-----------------------------------------------------------------|:--------------------|
| `vuid`, `idnumber`, `id`                                         | `id`                |
| `datecreated`, `datefirstpublished`, `publicdate`, `dateupdated` | `createDate`        |
| `dateupdated`, `datecreated`, `datefirstpublished`, `publicdate` | `updateDate`        |
| `author` & `thanks` & `Acknowledgements`                         | `acknowledgements`  |
| `public`                                                         | `references`        |
| `keywords`                                                       | `keywords`          |
| `cveids`                                                         | `referenceIds`      |
| `cvss_basevector` & `cvss_environmentalvector`                   | `cvss2`             |
| `name`, `Overview`, `clean_description`                          | `summary`           |
| longest(`Description`, `""`, `clean_description`)                | `description`       |
| `Impact`, `impact`                                               | `threat`            |
| `Solution`, `resolution`                                         | `recommendation`    |
| `Workarounds`, `workarounds`                                     | `workarounds`       |

---

### CERT-FR (advisory data) (`certfr-advisors` / `certFrAdvisorIndex`)

The TXT files provided by the CERT-FR are mere transcriptions of PDF files and are highly unstructured, lacking proper
segmentation and including header and footer on each page and PDF-specific formatting symbols. Each document
contains a table in the header that provides some general information, such as the document ID and dates. The table rows
appear in random order from document to document.

After the header, there are multiple titles followed by text content. These headers are not normalized, with 1800 unique
headers, where sometimes there are variations of headers and some appear only once. After detection the paragraphs, we
collect them with their respective header and text content. Some titles are normalized to an English identifier for
consistency.

1. Iterate over all TXT files in the directory
2. Read the contents of each file
3. Use `CertFrAdvisorEntry.fromDownloadText` to map the information to a `CertFrAdvisorEntry` object

| TXT                                                                                                                                             | CertSeiAdvisorEntry |
|:------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------|
| table > first line that matches CERT-FR identifier format                                                                                       | `id`                |
| table > `Date de la première version` OR first line that matches date                                                                           | `createDate`        |
| table > `Date de la dernière version` OR second line that matches date                                                                          | `updateDate`        |
| `Documentation` > every second line contains an URL with the line above being the title                                                         | `references`        |
| CERT-FR and CVEs in the entire text content                                                                                                     | `referenceIds`      |
| `Summar`, header > `Object:`                                                                                                                    | `summary`           |
| (if `Documentation` is absent: table > `sources`) & `Description` & all other further unstructured paragraphs that have not been used otherwise | `description`       |
| `Risk`                                                                                                                                          | `threat`            |
| `Recommendations` & `Solution`                                                                                                                  | `recommendation`    |
| `Temporary bypass`                                                                                                                              | `workarounds`       |

Valid table headers are:

- `Systèmes affectés`, `Affected systems`
- `Résumé`, `Summary`
- `Risque\\(s\\)`, `Risques`, `Risque`, `Risk`
- `Solution`, `Solutions`, `Solution`
- `Recommandations`, `Recommendations`
- `Documentation`, `Documentations`, `Documentation`
- `Contournement` `provisoire`, `Temporary bypass`
- `Description`, `Description`
- `Rappel des avis émis`, `Rappel des avis et des mises à jour émis`, `Rappel des avis et mises à jour émis`,
  `Reminder of notices issued`
- `^\\d{1,2} .+`

Examples:

- Please view the entry [CERTFR-2022-AVI-068](example-data/cert-fr-CERTFR-2022-AVI-068.txt) (online
  [https://www.cert.ssi.gouv.fr/avis/CERTFR-2022-AVI-068/](https://www.cert.ssi.gouv.fr/avis/CERTFR-2022-AVI-068/)).

  How would you split the contents? This is what our process sees:
    - [Removing unused lines](example-data/cert-fr-CERTFR-2022-AVI-068-PARSING-1.txt)
    - [Detection of segments](example-data/cert-fr-CERTFR-2022-AVI-068-PARSING-2.txt) (`##` stands for a comment by me)

  And this is the [result of a parsed file (JSON)](example-data/cert-fr-CERTFR-2022-AVI-068-PARSED.json).

---

### MSRC Products (`msrc-products` / `msrcProductIndex`)

When downloading the Microsoft Security Response Center data (MSRC), a list of affected products is included. The
majority of these products are developed by Microsoft. Each monthly file within the download contains only the products
that are affected by the advisories in that particular file. As a result, there may be multiple files with the same
product, each containing varying amounts of information. To generate a comprehensive list, all files must be parsed.

The product tree consists of two layers: vendors > multiple products with product families. Not all products have a
family, some are listed on the upper layer.

The product tree is organized into two layers: vendors and multiple products with product families. Most products are
child nodes of the vendors, but not all products have a family/vendor: some are listed on the upper layer directly.

| XML                                               | data structure |
|:--------------------------------------------------|:---------------|
| `FullProductName` > attribute `ProductID`         | `id`           |
| `FullProductName`                                 | `name`         |
| `Branch` > where `Type="Product Family"` > `Name` | `family`       |
| `Branch` > where `Type="Vendor"` > `Name`         | `vendor`       |

---

### MSRC Advisors (advisory data) (`msrc-advisors` / `msrcAdvisorIndex`)

The advisories provided in the MSRC download are each almost always linked to at least one CVE, which is also their ID.
Very rarely however, the ID may be an ADV\d+ identifier, that is not related a specific CVE.

Some of the AdvisorEntry-related fields such as workarounds, … cannot be filled out, as they relate to a specific
product.

| XML                                                              | MsrcAdvisorEntry     |
|:-----------------------------------------------------------------|:---------------------|
| `CVE` (with `MSRC` prefix)                                       | `id`                 |
| `RevisionHistory` > first `Revision` > `Date`                    | `createDate`         |
| `RevisionHistory` > latest `Revision` > `Date`                   | `updateDate`         |
| all CVE-IDs in the note elements                                 | `referenceIds`       |
| `CVSSScoreSets` > each `ScoreSet` > `Vector` & `ProductID`       | `productCvssVectors` |
| `Threats` > each `Threat` > `Type` & `Description` & `ProductID` | `msThreats`          |
| `Remediations` > each `Remediation` > multiple tags              | `msRemediations`     |
| `ProductStatuses` > each `Status` > `ProductID`                  | `affectedProducts`   |
| `Title`                                                          | `summary`            |
| `Notes` > each `Note` > (`Type` & `Title`) & (Text content)      | `description`        |
| `Threats` > first `Threat` without `ProductId`                   | `threat`             |

---

### MSRC KB Chains (`msrc-kb-chains` / `msrcKbChainIndex`)

For more details on how this index is built and how it can be used, see
[Understanding the MSRC data](../msrc/understanding-data.md) and related pages.

---

## List of deprecated downloads

These downloads either have already or will stop working in the future, due to API changes.

---

### Legacy NVD CVE/CPE Information

> :warning: In late 2023, the NVD will retire its legacy data feeds while working to guide any remaining data feed users
> to updated application-programming interfaces (APIs).

---

### CPE Dictionary (CPEs) (`cpe-dict-legacy-feed` / `cpeDictionaryIndex`)

The downloaded files come in JSON for the dictionary and XML for the match file. The JSON contains an array of objects,
that each have a CPE URI and multiple child-CPEs. The XML contains a list of cpe-item entries with a CPE as name and
multiple other CPEs in several data structure formats.

| JSON/XML                                                           | data structure                                                                                                           |
|:-------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------|
| if JSON: `cpe23Uri`<br/>else if XML: `cpe-item` > attribute `name` | `cpe23Uri`                                                                                                               |
| split CPE URI into parts                                           | `part`, `vendor`, `product`, `version`, `update`, `edition`, `language`, `sw_edition`, `target_sw`, `target_hw`, `other` |

| **XML**                                            | **data structure**  |
|:---------------------------------------------------|:--------------------|
| `title`                                            | `title`             |
| `references` > multiple reference                  | `references`        |
| `item-metadata` > attribute `nvd-id`               | `nvdId`             |
| `item-metadata` > attribute `deprecated-by-nvd-id` | `deprecatedByNvdId` |
| `item-metadata` > attribute `modification-date`    | `updateDate`        |

---

### CPE Dictionary Vendor Product (Vendor/Product pairs) (`cpe-dict-vp-legacy-feed` / `cpeDictionaryVendorProductIndex`)

For all vendors, store a set of their products.  
For all products, store a set of their vendors.

This is used for quickly accessing all vendors/products of a product/vendor. The list of entries is in CSV. The
information is extracted from the CPE Dictionary index, making the index required to be completed before this one.

| **index**                                                                      | **data structure** |
|:-------------------------------------------------------------------------------|:-------------------|
| if `vendor → products`: `vp`<br>else if `product → vendors`: `pv`              | `type`             |
| if `vp`: a single vendor<br>else if pv: a CSV list of vendors for the product  | `vendor`           |
| if `pv`: a single product<br>else if vp: a CSV list of products for the vendor | `product`          |

---

### NVD Vulnerabilities (CVE) (`nvd-cve-legacy-feed` / `nvdLegacyVulnerabilityIndex`)

No detail is provided for this index. If you want to know more, see `Vulnerability#fromNvdMirrorCveItem1_0()` in the
artifact analysis project.

---
