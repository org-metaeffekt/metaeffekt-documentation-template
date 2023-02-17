# KB Research

Understanding the MSRC KB Chain hierarchy data.

![Thumbnail](kb-chain-thumb.png)

One of the more convoluted segments of the node tree

References:

- MSRC Advisors: [Microsoft Update Catalog](https://www.catalog.update.microsoft.com)
- Main MSRC page:
  [Security Update Guide - Microsoft Security Response Center](https://msrc.microsoft.com/update-guide/vulnerability)
- API reference: [Microsoft Security Updates API | MSRC](https://api.msrc.microsoft.com/cvrf/v2.0/swagger/index)
- [From KBs to CVEs: Understanding the Relationships Between Windows Security Updates and Vulnerabilities](https://claroty.com/team82/blog/from-kbs-to-cves-understanding-the-relationships-between-windows-security-updates-and-vulnerabilities)

## Definitions & Facts

- the MSRC mirror contains ~6500 MSRC Advisors, which may reference security updates (KB) published by Microsoft
- security updates are identified by KB-Identifiers, e.g. KB5012118 from
  https://www.catalog.update.microsoft.com/ScopedViewInline.aspx?updateid=39b0464e-f56e-490d-b0fa-bbdde81d1755#PackageDetails
- these entries can each:
    - replace other KB entries by being a cumulative update, e.g.
      ```
      This update replaces the following updates:
      2022-01 Cumulative Update for .NET Framework 4.8 for Windows 10 Version 1607 (KB5008877)
      2022-02 Cumulative Update for .NET Framework 4.8 for Windows 10 Version 1607 (KB5010460)
      ```
      be replaced by others, e.g.
      ```
      This update has been replaced by the following updates.
      2022-05 Cumulative Update for .NET Framework 4.8 for Windows 10 Version 1607 (KB5013625)
      ```
- superseded identifiers format:
    - multiple identifiers split by `;`, `,`, `<br><br>`
        - 7-digit identifiers (`4528760`)
        - references to other Microsoft Security Bulletins (`MS16-016`)
        - None
        - a singular entry `50185` with only *5* digits on `MSRC-CVE-2022-41064`, which seems to be an incomplete
          reference to `5018544`
        - a singular entry `982666` with only *6* digits
          ([Microsoft Update Catalog](https://www.catalog.update.microsoft.com/ScopedViewInline.aspx?updateid=3a3177ac-957a-495c-88b8-dc89eb2403bd))
    - they may contain ` ` or `\n` at the beginning/end/in between elements of the list
    - when split by `;`, they reference Microsoft Security Bulletins with KB-Ids in this format: `MSxx-xxx, xxxxxxx`,
      e.g. `MS16-016, 3124280; MS16-097, 3178034;`.
    - since we do not mirror the MS Bulletins, we can drop the bulletin IDs.
- every relation between `KB ↔︎ KB` and `KB ↔︎ CVE/ADV` is contained behind a MS product Id, meaning it can only be
  used, if the referenced product is used

## Data Sources

### Sources

- [Security Update Guide - Microsoft Security Response Center](https://msrc.microsoft.com/update-guide)
    - can **manually** be downloaded as multiple csv files, one per year. Time frame has to be set manually.
    - contains `CVE/ADV ↔︎ KB` relations that are not present in the other sources
    - does not contain `KB ↔︎ KB` relations
    - a short how-to can be found [here](performing-csv-download.md)
- [Microsoft Security Updates API | MSRC](https://api.msrc.microsoft.com/cvrf/v2.0/swagger/index)
    - can **automatically** be mirrored using our process (see below)
    - contains `CVE/ADV ↔︎ KB` relations that are not present in the other sources
    - contains `KB ↔︎ KB` relations
    - only contains relations that have a MS Security Update Advisor
- [Microsoft Update Catalog](https://www.catalog.update.microsoft.com/Home.aspx)
    - **cannot** be mirrored (no API/download available)
    - contains `KB ↔︎ KB` relations
    - does not contain `KB ↔︎ CVE/ADV` relations

### Problems with the data sources

- only one of the three data sources can be retrieved automatically. The one available for mirroring is the most
  important one, yet it still misses a lot of information.
- the data in between the different sources is inconsistent. Every data source either contains `CVE/ADV → KB`
  or `KB → KB`relations that are missing in the other sources. The Update Catalog knows about this information, but is
  inconsistent in itself.  
  An example for `KB4499409`:  
  **In the API**: the KB replaces (`4487259` and `4487081`) and is replaced by `4507423`
  ![Example](kb-chain-example-1.png)
  **In the Update Catalog**:
  [Update Catalog](https://www.catalog.update.microsoft.com/ScopedViewInline.aspx?updateid=1237f59d-2dcf-4be5-ad58-3448a5b99491#PackageDetails)
  `4499409` replaces (`4487259` and `4487081`), but is not replaced by `4507423`. When looking at the entry `4507423`,
  it can be seen that it replaces `4499409`.
- this means, our data will never be complete unless considering all three data sources, which is impossible to
  automate. it is reasonable to manually download the csv files from the MSRC, but scraping the Update Catalog is not
  feasible, manually or automated.
- the MSRC csv has to be downloaded in time segments of one year, which have to be set manually, which takes quite some
  time

## Data mirror

### Getting the data

1. **Data structure used**  
   The data structure used to store a KB identifier and it’s dependencies is a node-based graph. A Node has these
   properties:

    - `String kbId`
    - `Map<String, ReferenceEntry> relations` with the product Id as key (or name if not available, which is only the
      case
      on very few entries)

   Where a `ReferenceEntry` contains:

    - `Set<String> affectedVulnerabilities`
    - `Set<Node> supersededBy`
    - `Set<Node> supersedes`
2. **Get KBs from MSRC Security Update Guide**
    - go to the Security Update
      Guides [Security Update Guide - Microsoft Security Response Center](https://msrc.microsoft.com/update-guide)
      website. Make sure to be in the `All` section.  
      You cannot download all entries at once - only ones in a certain time frame (max. one year). Download the csv
      files from as many time-frames as you need.
      This may take quite some time, so consider filtering the data to only the CVE that interest you.
    - for every line in every document you downloaded:
        - if the `Article` is a KB identifier (see criteria above), check if a `Node` with the KB already exists,
          otherwise create a new one (`current`).
          There are two columns named Article, select the first one.
        - get the product name from `Product` and find the corresponding product id from the `MsrcProductIndexQuery`. If
          not available, use the name.
        - if the `ReferenceEntry` for that product Id does not yet exist, create a new one
        - add the CVE-identifier from `Details` to `affectedVulnerabilities` to the `ReferenceEntry` with the product
          Id/name of `current`.
    - store the result
3. **Get KBs from MSRC Api**
    - download all monthly detail files (see
      [MSRC Download](../mirror/download.md#msrc--advisory-dataproduct-mappings---msrc-))
    - create index from downloaded files (see [MSRC Index](../mirror/download.md))
    - for every advisor in the data set iterate over all remediations provided
        - get the supersedence, description and affected product Ids
        - if the description is a KB identifier (see criteria above), check if a `Node` with the KB already exists,
          otherwise create a new one (`current`)
        - set the `kbId` of `current` to the description
        - for every product Id:
            - if the `ReferenceEntry` for that product Id does not yet exist, create a new one on `current`
            - get the entry-id and add it to `affectedVulnerabilities` to the `ReferenceEntry`
            - split the supersedence into multiple KB identifiers (see criteria above) and for every one:
                - check if a `Node` with the KB already exists, otherwise create a new one (`ref`)
                - add `ref` to `supersedes` to the `ReferenceEntry`
                - add `current` to `supersededBy` to the `ReferenceEntry`
    - store the result
4. **Merging the KB Nodes**
   Make sure to update the references of supersededBy and supersedes to the new merged list. This can be quite tricky to
   get right.  
   Advantages of the data from:
    - MSRC Security Update Guide: Contains a CVE/ADV that would be missing in the Api data
    - MSRC Api: Contains references in between KB Identifiers

<details>
  <summary>Example data for ...</summary>

... a remediation entry in the MSRC API

```json
{
  "description": "5012118",
  "subType": "Security Update",
  "type": "Vendor Fix",
  "url": {
    "title": "5012118",
    "url": "https://catalog.update.microsoft.com/v7/site/Search.aspx?q=KB5012118"
  },
  "fixedBuild": "4.8.4494.03",
  "affectedProductIds": [
    "11650-10816",
    "11650-10852",
    "11650-10853",
    "11650-10855"
  ],
  "supercedence": "5008877"
}
```

... a parsed entry from the MSRC Security Update Guide

```json
{
  "kbId": "5008631",
  "rel": {
    "11908": {
      "vuln": ["CVE-2022-21855", "CVE-2022-21846", "CVE-2022-21969"],
      "supBy": [],
      "sup": []
    },
    "11682": {
      "vuln": ["CVE-2022-21855", "CVE-2022-21846", "CVE-2022-21969"],
      "supBy": [],
      "sup": []
    }
  }, ...
}
```

... a parsed entry from the MSRC Api

```json
{
  "kbId": "3203467",
  "rel": {
    "10528": {
      "vuln": ["CVE-2017-8508", "CVE-2017-8507", "CVE-2017-8506"],
      "supBy": ["2956078"],
      "sup": ["3118388"]
    },
    "10527": {
      "vuln": ["CVE-2017-8508", "CVE-2017-8507", "CVE-2017-8506"],
      "supBy": ["2956078"],
      "sup": ["3118388"]
    }
  }
}
```

</details>

### Data inconsistencies

As already mentioned above, the data sources are inconsistent between each other. Expand the box below to see the
differences in the MSRC Security Update Guide CSV and the MSRC Api.


<details>
  <summary>Differences as of 2023-01-18</summary>

```
File [2016.csv] with [459] entries:
  - new KB nodes: [0]
  - new products relations: [6310]
  - vulnerabilities that caused new relations: [66]
  - new vulnerabilities (not in Api): [0]
File [2017.csv] with [568] entries:
  - new KB nodes: [0]
  - new products relations: [9389]
  - vulnerabilities that caused new relations: [102]
  - new vulnerabilities (not in Api): [0]
File [2018.csv] with [722] entries:
  - new KB nodes: [11]
  - new products relations: [16296]
  - vulnerabilities that caused new relations: [48]
  - new vulnerabilities (not in Api): [1]
File [2019.csv] with [519] entries:
  - new KB nodes: [0]
  - new products relations: [15464]
  - vulnerabilities that caused new relations: [22]
  - new vulnerabilities (not in Api): [0]
File [2020.csv] with [627] entries:
  - new KB nodes: [0]
  - new products relations: [12540]
  - vulnerabilities that caused new relations: [150]
  - new vulnerabilities (not in Api): [0]
File [2021.csv] with [505] entries:
  - new KB nodes: [0]
  - new products relations: [2194]
  - vulnerabilities that caused new relations: [27]
  - new vulnerabilities (not in Api): [0]
File [2022.csv] with [464] entries:
  - new KB nodes: [2]
  - new products relations: [5396]
  - vulnerabilities that caused new relations: [176]
  - new vulnerabilities (not in Api): [0]
File [2023.csv] with [27] entries:
  - new KB nodes: [0]
  - new products relations: [13]
  - vulnerabilities that caused new relations: [0]
  - new vulnerabilities (not in Api): [0]
```

Where

- `new KB nodes` are the KB entries that were not known yet
- `new products relations` are the amount of new product relations on KB entries
- `vulnerabilities that caused new relations` are the unique vulnerabilities that were not present in at least one KB
  relation
- `new vulnerabilities (not in Api)` are the “*real*” new vulnerabilities that were completely absent in the MSRC Api

</details>

Meaning in total, there are:

- **13** new KB
  nodes: `5005112, 5005412, 5016129, 5016987, 5018922, 5014024, 5016990, 5017397, 5017396, 5016263, 4586863, 5001400, 5005260`
- **67.602** new product relations, out of which there are **583** unique products
- **591** vulnerabilities that might have been known to some, but not all
  relations: `CVE-2021-42285, CVE-2019-1080, CVE-2019-1081, CVE-2021-42283, CVE-2021-42284, CVE-2016-7202, CVE-2021-42280, ...`
- **1** vulnerability that was completely unknown to the MSRC Api, which is a MSRC advisory: `ADV990001`
  note that this is not really a vulnerability, but an advisor that contains SSU Package information for different
  Windows versions, which is referenced by almost every monthly API document in the
  notes: [https://msrc.microsoft.com/update-guide/en-us/vulnerability/ADV990001](https://msrc.microsoft.com/update-guide/en-us/vulnerability/ADV990001)

*... TODO ...*
