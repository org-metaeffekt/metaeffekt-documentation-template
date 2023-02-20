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
```

Examples:

- Archive: [https://www.cert.ssi.gouv.fr/tar/2000.tar](https://www.cert.ssi.gouv.fr/tar/2000.tar)
- Advisory CERTFR-2020-ACT-013: [local copy](example-data/cert-fr-CERTFR-2020-ACT-013.txt) or HTML version
  [https://www.cert.ssi.gouv.fr/actualite/CERTFR-2020-ACT-013/](https://www.cert.ssi.gouv.fr/actualite/CERTFR-2020-ACT-013/)

### MSRC (advisory data/product mappings) (`msrc`)

### NVD CPE Dictionary (`cpe-dict-legacy-feed`)

### NVD CVE Information (`nvd-legacy-feed`)

### NVD CPE API (`cpe-dict`) and NVD CVE API (`nvd`)
