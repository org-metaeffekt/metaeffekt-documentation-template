# Downloads

This chapter will not go into detail about the contents of the downloads, as this is covered in the [index](index.md)
step of the mirroring process.

## CERT-SEI (advisory data) (`certsei`)

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

## CERT-FR (advisory data) (`certfr`)

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

## MSRC (advisory data/product mappings) (`msrc`)

## NVD CPE Dictionary (`cpe-dict-legacy-feed`)

## NVD CVE Information (`nvd-legacy-feed`)

## NVD CPE API (`cpe-dict`) and NVD CVE API (`nvd`)
