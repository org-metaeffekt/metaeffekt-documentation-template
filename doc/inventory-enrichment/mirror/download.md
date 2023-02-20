> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Mirror](mirror-overview.md) > Downloads

# Downloads

This chapter will describe:

- what data
- in what format
- from what sources

can be pulled using the download processes.

It will not go into detail about the actual file contents of the downloads, as this is covered in the [index](index.md)
step of the mirroring process. These descriptions only reflect the actual downloading part of the downloads, for the
wrapping process, view [common steps](#common-steps) below.

<!-- TOC -->

* [Downloads](#downloads)
    * [Common steps](#common-steps)
        * [Some more context for downloading](#some-more-context-for-downloading)
    * [List of downloads](#list-of-downloads)
        * [CERT-SEI (advisory data) (`certsei`)](#cert-sei--advisory-data---certsei-)
        * [CERT-FR (advisory data) (`certfr`)](#cert-fr--advisory-data---certfr-)
        * [MSRC (advisory data/product mappings) (`msrc`)](#msrc--advisory-dataproduct-mappings---msrc-)
        * [MSRC CSV (KB chains) (`msrc-csv`)](#msrc-csv--kb-chains---msrc-csv-)
        * [NVD CPE Dictionary (`cpe-dict-legacy-feed`)](#nvd-cpe-dictionary--cpe-dict-legacy-feed-)
        * [NVD CVE Information (`nvd-legacy-feed`)](#nvd-cve-information--nvd-legacy-feed-)
        * [NVD CPE API (`cpe-dict`) and NVD CVE API (`nvd`)](#nvd-cpe-api--cpe-dict--and-nvd-cve-api--nvd-)

<!-- TOC -->

## Common steps

Every download data source in encapsulated in a single class that extends `Download`. The downloaded files are stored in
a directory `BASE DIR/download/DOWNLOAD NAME`. The individual downloader manages the internal structure of the download
by itself.

When a download is asked to initialize/update the downloaded data, it will only do so if one of these criteria is met:

- the download is not yet present at all
- the last update is further back than a specified time (default: 1 day)
- the remote datasets have changed since the last update, this is different from download to download

Every download is unique and differs in terms of data source, format, and size, which is why each one is implemented
very differently. This is the main process that they all share:

- wait for the directory to be unlocked. Other downloads/indexes can lock the directory if they require the directory
  not to be changed. The default timeout for this is 10 minutes.
- lock the directory to prevent other processes to write/read the download information in parallel.
- if the initial download is older than 4 weeks, the entire download directory is reset to fix any broken information.
  This is done to prevent outdated and potentially incorrect data from being stored for an extended period of time. In
  the past, data sources have accidentally provided invalid data, leading to it being stored in the local download. Even
  when the data sources corrected the mistake, the local download still held the invalid information.
- check whether a download is required at all using the criteria listed above. If not, abort the process now.
- if the download is required: [perform the individual download step from the downloader](#list-of-downloads)
- unlock the directory

Some more information:

- downloading data may sometimes fail due to service unavailability or network issues. To mitigate this, the process
  will retry requests a few times before finally failing. Although the mirroring process will continue, the failed
  download will be marked as broken. This allows the index structures to detect and skip the indexing of broken
  downloads.
- some requests to the data sources can be parallelized, as the data downloaded has to be processed and more requests
  can be made during that time. The individual process can define how many threads should be launched in parallel, with
  a maximum of the amount of cores available.

A full list of all download processes can be found in [download.md](download.md).

### Some more context for downloading

In contrast to the previous implementation of the data mirror, all downloads and indexers are now triggered by a single
Maven goal to reduce the amount of configurations necessary to perform a full mirror. This goal is found in:
`com.metaeffekt.artifact.analysis` : `ae-mirror-plugin` : `data-mirror`

Every class that implements `Download` must also declare an enum that implements `ResourceLocation`. In this enum, the
required data source URIs with format string placeholders can be stored. For example:

```java
public enum ResourceLocationCertSei implements ResourceLocation {
    SUMMARY_API_URL("https://kb.cert.org/vuls/api/%d/summary/"),
    NOTES_API_URL("https://kb.cert.org/vuls/api/%s/")
}
```

This allows the user to customize the data sources, in case the data is stored on a different server than the default
one. When using the `DownloadInitializer` class within the `ae-inventory-enrichment-plugin` POM, a list of
`resourceLocations` can be provided, like this:

```
<certSeiDownload>
    <resourceLocations>
        <SUMMARY_API_URL>https://kb.cert.org/vuls/api/%d/summary/</SUMMARY_API_URL>
    </resourceLocations>
</certSeiDownload>
```

For all download resource locations, see the [mirror pom.xml file line ~55](../../../mirror/pom.xml), where a short
description of all of them can be found, as well as their default values.

## List of downloads

### CERT-SEI (advisory data) (`certsei`)

References:

- Data provider: [Software Engineering Institute](https://www.sei.cmu.edu/)
- API reference:
  [Vulnerability Note API - VINCE - VulWiki](https://vuls.cert.org/confluence/display/VIN/Vulnerability+Note+API)

In order to find what documents exist, the summary-API is used. These summaries are provided by year and in a JSON
format. The starting year is 2000, which is why all summaries are downloaded from 2000 to the current year.

These summaries contain all notes (advisors) that were published in that year. The ID of each note is used to download
the individual notes.

To store the files locally, one directory per year is created, where the advisors are written to. The filename is
`VU#[ID].json`.

```
.
├── 2000
│   ├── VU#111677.json
│   ├── VU#17566.json
...
└── 2022
    ├── VU#119678.json
...
```

Examples:

- Summary: [local copy](example-data/cert-sei-summary-2004.json) or
  [https://kb.cert.org/vuls/api/2004/summary/](https://kb.cert.org/vuls/api/2004/summary/)
- Advisor VU#975041: [local copy](example-data/cert-sei-advisor-VU%23975041.json) or
  [https://kb.cert.org/vuls/id/975041](https://kb.cert.org/vuls/id/975041)

### CERT-FR (advisory data) (`certfr`)

References:

- Data provider: [CERT-FR](https://www.cert.ssi.gouv.fr/)
- Archive download: [Archive 2022](https://www.cert.ssi.gouv.fr/2022/)

The CERT-FR provides yearly archives in the form of TAR files, that contain all published notes in a PDF and a TXT
variant. All files are extracted and put into a directory with the year as name. All PDF files are discarded, as they
are not machine-readable. The remaining TXT files are stored in files with a filename of `CERTA-[YEAR]-[TYPE]-[ID].txt`.
The advisories start from 2000, meaning that all tar files from 2000 to the current year are downloaded and extracted.

The TXT files come in a wildly unstructured format, being simple transcripts of the PDF files. This makes parsing them
quite the challenge. For more information on this, see the index process for the CERT-FR advisories.

```
.
├── 2000
│   ├── CERTA-2000-ALE-001.txt
│   ├── CERTA-2000-ALE-002.txt
...
└── 2022
    ├── CERTFR-2022-ACT-001.txt
...
```

Examples:

- Archive: [https://www.cert.ssi.gouv.fr/tar/2000.tar](https://www.cert.ssi.gouv.fr/tar/2000.tar)
- Advisory CERTFR-2020-ACT-013: [local copy](example-data/cert-fr-CERTFR-2020-ACT-013.txt) or HTML version
  [https://www.cert.ssi.gouv.fr/actualite/CERTFR-2020-ACT-013/](https://www.cert.ssi.gouv.fr/actualite/CERTFR-2020-ACT-013/)

### MSRC (advisory data/product mappings) (`msrc`)

References:

- MSRC Homepage: [Microsoft Security Response Center](https://msrc.microsoft.com/)
- MSRC CVRF API: [Microsoft Security Updates API](https://api.msrc.microsoft.com/cvrf/v2.0/swagger/index)

The MSRC splits their data into three sources, you can learn more about them
[in this document](../msrc/understanding-data.md). This download is the only one of the three that can be performed
automatically via the MSRC CVRF API.

Just like with the CERT-SEI, the download is split into two parts: A summary (update) API and the actual advisor/product
contents API.

1. All documents available are contained within the XML document available via
   [https://api.msrc.microsoft.com/cvrf/v2.0/updates](https://api.msrc.microsoft.com/cvrf/v2.0/updates). This document
   contains multiple `CvrfUrl` tags, that are collected into a list. The MSRC structures their advisors into one
   document per month, so each URL will lead to a different monthly XML file.
2. The downloader checks whether it already knows these documents/whether they are up-to-date.
3. All unknown/incomplete `CvrfUrl` URLs are downloaded.

These files are stored in one directory per year (starting 2016), with paths in the form of `[YEAR]/[YEAR]-[MONTH].xml`.

```
.
├── 2016
│   ├── 2016-Apr.xml
│   ├── 2016-Aug.xml
...
└── 2023
    └── 2023-Jan.xml
```

Examples:

- Summary/Updates: [local copy](example-data/msrc-updates.xml) or
  [https://api.msrc.microsoft.com/cvrf/v2.0/updates](https://api.msrc.microsoft.com/cvrf/v2.0/updates)
- Document: msrc-2016-Apr.xml: [local copy](example-data/msrc-2016-Apr.xml) or
  [https://api.msrc.microsoft.com/cvrf/v2.0/document/2016-Apr](https://api.msrc.microsoft.com/cvrf/v2.0/document/2016-Apr)

### MSRC CSV (KB chains) (`msrc-csv`)

References:

- Update Guide/CSV download: [https://msrc.microsoft.com/update-guide](https://msrc.microsoft.com/update-guide)
- Understanding the MSRC Download: [understanding-data.md](../msrc/understanding-data.md)

As mentioned in [MSRC advisory data/product mappings](#msrc--advisory-dataproduct-mappings---msrc-), the MSRC splits its
data into three separate data sources. This is the one that is manually downloadable.

Please see [understanding-data.md](../msrc/understanding-data.md#getting-the-data) for a small tutorial on how to obtain
the CSV files.

The downloader will create a directory `msrc-csv` for you in the `download` directory, place all your yearly CSV files
into this directory. The index will automatically pick up any CSV file provided in this directory.

```
.
├── 2016.csv
├── 2017.csv
├── 2018.csv
├── 2019.csv
├── 2020.csv
├── 2021.csv
├── 2022.csv
└── 2023.csv
```

Examples:

- CSV file 2023: [local copy](example-data/msrc-csv-2023.csv)

### NVD CPE Dictionary (`cpe-dict-legacy-feed`)

> :warning: In late 2023, the NVD will retire its legacy data feeds while working to guide any remaining data feed users
> to updated application-programming interfaces (APIs).

References:

- NVD Data Feeds: [NVD - Data Feeds](https://nvd.nist.gov/vuln/data-feeds)
- CPE Dictionary: [NVD - CPE](https://nvd.nist.gov/products/cpe)
- CPE Match Feed: [NVD - Data Feeds](https://nvd.nist.gov/vuln/data-feeds#cpeMatch)

The NVD provides two files that, when combined, contain all versioned CPE:

- The **CPE Dictionary** contains most base CPE, many without all the versions  
  [https://nvd.nist.gov/feeds/xml/cpe/dictionary/official-cpe-dictionary_v2.2.xml.zip](https://nvd.nist.gov/feeds/xml/cpe/dictionary/official-cpe-dictionary_v2.2.xml.zip)
- The **Match File** mainly contains versioned CPE with a reference to their base CPE  
  [https://nvd.nist.gov/feeds/json/cpematch/1.0/nvdcpematch-1.0.json.zip](https://nvd.nist.gov/feeds/json/cpematch/1.0/nvdcpematch-1.0.json.zip)

These two files are downloaded and extracted into `cpe-dict.xml` and `cpe-match.json`.

```
.
├── cpe-dict.xml
└── cpe-match.json
```

Examples:

- CPE Dictionary: [local copy](example-data/cpe-dict-cpe-dict.xml)
- CPE Match: [local copy](example-data/cpe-dict-cpe-match.json)

*These files are heavily trimmed, as they are usually ~600 MB each.*

### NVD CVE Information (`nvd-legacy-feed`)

> :warning: In late 2023, the NVD will retire its legacy data feeds while working to guide any remaining data feed users
> to updated application-programming interfaces (APIs).

References:

- NVD Data Feeds: [NVD - Data Feeds](https://nvd.nist.gov/vuln/data-feeds)
- NVD Vulnerability Feed: [NVD - Data Feeds/JSON](https://nvd.nist.gov/vuln/data-feeds#JSON_FEED)

The NVD provides

- multiple archives `year` each containing one year worth of vulnerabilities. The `year` feeds are updated once per day.
- two files `recent` and `modified` that contain what vulnerabilities have been updated lately. These feeds are updated
  every two hours.

If the download does not exist yet, all `year` archives are downloaded and extracted. If year files are missing, it is
re-downloaded and extracted. The `modified` is checked for new vulnerabilities and if there are new ones, they are
integrated into the year files.

In order to be able to compare the last `modified` file with the latest, it is also downloaded and stored. The `year`
files are plainly stored in the download directory.

```
.
├── nvd-2002.json
├── nvd-2003.json
├── nvd-2004.json
...
├── nvd-2022.json
├── nvd-2023.json
└── nvd-modified.json
```

Examples:

- Year file 2003: [local copy](example-data/nvd-cve-nvd-2003.json) or
  [https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-2003.json.gz](https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-2003.json.gz)
- Modified file: Same structure as [year files local copy](example-data/nvd-cve-nvd-2003.json), or
  [https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-modified.json.gz](https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-modified.json.gz)

### NVD CVE API (`nvd`)

> :heavy_check_mark: This is the new and preferred way of mirroring the NVD data, as the old data feeds are retired end
> of 2023.

References:

- TODO

```
.
├── 1999.json
├── 2000.json
├── 2001.json
├── 2002.json
...
├── 2022.json
└── 2023.json
```

## NVD CPE API (`cpe-dict`)

TODO
