> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > Mirror

# Data sources mirror overview

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

## Examples

Java:

Commented out download/index classes are deprecated

```java
final String MIRROR_NVD_API_KEY = "";

// download
new CertSeiDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
new CertFrDownload(MIRROR_DIRECTORY).performDownloadIfRequired();

// new NvdDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
new NvdCveApiDownload(MIRROR_DIRECTORY)
        .setApiKey(MIRROR_NVD_API_KEY)
        .performDownloadIfRequired();

// new CpeDictionaryDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
new NvdCpeApiDownload(MIRROR_DIRECTORY)
        .setApiKey(MIRROR_NVD_API_KEY)
        .performDownloadIfRequired();

new MsrcDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
new MsrcManualCsvDownload(MIRROR_DIRECTORY).performDownloadIfRequired(); // manual download


// index
new CertSeiAdvisorIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new CertFrAdvisorIndex(MIRROR_DIRECTORY).createIndexIfRequired();

// new CpeDictionaryIndex(MIRROR_DIRECTORY).createIndexIfRequired();
// new CpeDictionaryVendorProductIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new NvdCpeApiIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new NvdCpeApiVendorProductIndex(MIRROR_DIRECTORY).createIndexIfRequired();

// new NvdVulnerabilityIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new NvdCveApiIndex(MIRROR_DIRECTORY).createIndexIfRequired();

new MsrcProductIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new MsrcAdvisorIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new MsrcKbChainIndex(MIRROR_DIRECTORY).createIndexIfRequired();
```

Maven:  
A full example with all configuration options can be [found here](../../../mirror/pom.xml).  
As mentioned above, a single goal is enough to create both the download and the index for all data sources. Only
mentioning a mirror phase like `<msrcDownload/>` is enough to trigger it. All of them can be found below.  
You can specify an `active` flag for any of the phases to disable the process while keeping the configuration.  
The proxy information can be specified on a global level or for each download individually.

```xml
<build>
  <!-- ... -->
  <plugins>
    <plugin>
      <groupId>com.metaeffekt.artifact.analysis</groupId>
      <artifactId>ae-mirror-plugin</artifactId>
      <version>${ae.artifact.analysis.version}</version>

      <executions>
        <execution>
          <id>data-mirror</id>
          <goals>
            <goal>data-mirror</goal>
          </goals>

          <configuration>
            <mirrorDirectory>
              ${input.database}
            </mirrorDirectory>

            <proxyScheme>${proxy.scheme}</proxyScheme>
            <proxyHost>${proxy.host}</proxyHost>
            <proxyUsername>${proxy.user}</proxyUsername>
            <proxyPassword>${proxy.pass}</proxyPassword>
            <proxyPort>${proxy.port}</proxyPort>

            <!-- Downloads -->

            <certSeiDownload>
              <resourceLocations>
                <!-- Summary URL for a given year.
                     - %s Summary year (example: 2020) -->
                <SUMMARY_API_URL>https://kb.cert.org/vuls/api/%d/summary/</SUMMARY_API_URL>
                <!-- URL for a certain note.
                     - %s Note Identifier (example: 257161) -->
                <NOTES_API_URL>https://kb.cert.org/vuls/api/%s/</NOTES_API_URL>
              </resourceLocations>
            </certSeiDownload>

            <certFrDownload>
              <resourceLocations>
                <!-- Yearly archive download URL.
                     - %d Archive year (example: 2020) -->
                <CERT_FR_ARCHIVE>https://www.cert.ssi.gouv.fr/tar/%d.tar</CERT_FR_ARCHIVE>
                <!-- RSS feed that contains the latest changes to the mirror. Used to check if update is required. -->
                <CERT_FR_RSS_FEED>https://www.cert.ssi.gouv.fr/feed/</CERT_FR_RSS_FEED>
              </resourceLocations>
            </certFrDownload>

            <nvdCveDownload>
              <!-- you will need an API key in order to download the NVD data:
                   https://nvd.nist.gov/developers/request-an-api-key
                   more information: https://nvd.nist.gov/developers/start-here -->
              <apiKey>${nvd.apikey}</apiKey>

              <resourceLocations>
                <!-- - %d startIndex: 0-based index of the first CVE to be returned in the response data -->
                <CVE_API_LIST_ALL>https://services.nvd.nist.gov/rest/json/cves/2.0?startIndex=%d</CVE_API_LIST_ALL>
                <!-- The maximum allowable range when using any date range parameters is 120 consecutive days.
                     Values must be entered in the extended ISO-8061 date/time format: [YYYY][“-”][MM][“-”][DD][“T”][HH][“:”][MM][“:”][SS][Z]
                     - %d startIndex: 0-based index of the first CVE to be returned in the response data
                     - %s lastModStartDate: the start date
                     - %s lastModEndDate: the end date
                -->
                <CVE_API_START_END_DATE>https://services.nvd.nist.gov/rest/json/cves/2.0/?startIndex=%d&amp;lastModStartDate=%s&amp;lastModEndDate=%s</CVE_API_START_END_DATE>
              </resourceLocations>
            </nvdCveDownload>

            <nvdCpeDownload>
              <!-- you will need an API key in order to download the NVD data:
                   https://nvd.nist.gov/developers/request-an-api-key
                   more information: https://nvd.nist.gov/developers/start-here -->
              <apiKey>${nvd.apikey}</apiKey>

              <resourceLocations>
                <!-- API URL for the NVD CPE API (cpes) with a start index parameter.
                     - %d startIndex 0-based index of the first CPE to be returned in the response data -->
                <CPE_API_LIST_ALL>https://services.nvd.nist.gov/rest/json/cpes/2.0?startIndex=%d</CPE_API_LIST_ALL>
                <!-- API URL for the NVD CPE API (cpes) with a start index and start/end timestamp parameter.
                     The maximum allowable range when using any date range parameters is 120 consecutive days.
                     Values must be entered in the extended ISO-8061 date/time format:
                     [YYYY][“-”][MM][“-”][DD][“T”][HH][“:”][MM][“:”][SS][Z]
                     - %d startIndex 0-based index of the first CPE to be returned in the response data
                     - %s lastModStartDate the start date
                     - %s lastModEndDate the end date
                -->
                <CPE_API_START_END_DATE>https://services.nvd.nist.gov/rest/json/cpes/2.0?startIndex=%d&amp;lastModStartDate=%s&amp;lastModEndDate=%s</CPE_API_START_END_DATE>
                <!-- API URL for the NVD CPE API (cpematch) with a start index parameter.
                     - startIndex 0-based index of the first CPE to be returned in the response data -->
                <CPE_MATCH_API_LIST_ALL>https://services.nvd.nist.gov/rest/json/cpematch/2.0?startIndex=%d</CPE_MATCH_API_LIST_ALL>
                <!-- API URL for the NVD CPE API (cpematch) with a start index and start/end timestamp parameter.
                     The maximum allowable range when using any date range parameters is 120 consecutive days.
                     Values must be entered in the extended ISO-8061 date/time format:
                     [YYYY][“-”][MM][“-”][DD][“T”][HH][“:”][MM][“:”][SS][Z]
                     - %d startIndex 0-based index of the first CPE to be returned in the response data
                     - %s lastModStartDate the start date
                     - %s lastModEndDate the end date
                -->
                <CPE_MATCH_API_START_END_DATE>https://services.nvd.nist.gov/rest/json/cpematch/2.0?startIndex=%d&amp;lastModStartDate=%s&amp;lastModEndDate=%s</CPE_MATCH_API_START_END_DATE>
              </resourceLocations>
            </nvdCpeDownload>

            <msrcDownload>
              <resourceLocations>
                <!-- List of all monthly documents. Contains last update date used to determine whether an update is required.
                     When viewed in a browser, the content will be displayed as XML, but when accessed via the API, the content
                     will be returned as JSON. -->
                <MSRC_UPDATES_URL>https://api.msrc.microsoft.com/cvrf/v2.0/updates</MSRC_UPDATES_URL>
                <!-- REST-API for the Microsoft Security Response Center (MSRC) Common Vulnerability Reporting Framework (CVRF) v2.0.
                     https://api.msrc.microsoft.com/cvrf/v2.0/swagger/index
                     - %s CVRF document ID (yyyy-mmm) (example: 2021-dec)
                 -->
                <MSRC_CVRF_BASE_URL>https://api.msrc.microsoft.com/cvrf/v2.0/cvrf/%s</MSRC_CVRF_BASE_URL>
              </resourceLocations>
            </msrcDownload>

            <msrcCsvDownload/>

            <!-- deprecated, use nvdCveDownload -->
            <nvdLegacyDownload>
              <active>false</active>

              <resourceLocations>
                <!-- The URL to retrieve the recently modified and added CVE entries (last 8 days) using the JSON data feeds.
                     modified feeds are updated every two hours. -->
                <CVE_MODIFIED_URL>https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-modified.json.gz</CVE_MODIFIED_URL>
                <!-- Meta-information on the last modified and added CVE entries, such as the last modified date. -->
                <CVE_MODIFIED_META_URL>https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-modified.meta</CVE_MODIFIED_META_URL>
                <!-- The URL to get a specific yearly CVE list using the JSON data feeds.
                     - %d Year (example: 2022) -->
                <CVE_YEAR_BASE_URL>https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-%d.json.gz</CVE_YEAR_BASE_URL>
                <!-- Meta-information on the specific year files, such as the last modified date.
                     Content is of style: key:value
                     - %d Year (example: 2022) -->
                <CVE_YEAR_META_URL>https://nvd.nist.gov/feeds/json/cve/1.1/nvdcve-1.1-%d.meta</CVE_YEAR_META_URL>
              </resourceLocations>
            </nvdLegacyDownload>

            <!-- deprecated, use nvdCpeDownload -->
            <cpeDictionaryDownload>
              <active>false</active>

              <resourceLocations>
                <!-- The official CPE dictionary: https://nvd.nist.gov/products/cpe -->
                <CPE_DICTIONARY_URL>https://nvd.nist.gov/feeds/xml/cpe/dictionary/official-cpe-dictionary_v2.2.xml.zip</CPE_DICTIONARY_URL>
                <!-- The CPE match data feed contains additional information on the specific CPE metadata:
                     https://nvd.nist.gov/vuln/data-feeds#cpeMatch -->
                <CPE_MATCH_URL>https://nvd.nist.gov/feeds/json/cpematch/1.0/nvdcpematch-1.0.json.zip</CPE_MATCH_URL>
              </resourceLocations>
            </cpeDictionaryDownload>

            <!-- Indexers -->

            <certSeiAdvisorIndex/>

            <certFrAdvisorIndex/>

            <nvdVulnerabilityIndex/>

            <nvdCpeIndex/>

            <nvdCpeVendorProductIndex/>

            <msrcProductIndex/>

            <msrcAdvisorIndex/>

            <msrcKbChainIndex/>

            <!-- deprecated, use nvdVulnerabilityIndex -->
            <nvdLegacyVulnerabilityIndex>
              <active>false</active>
            </nvdLegacyVulnerabilityIndex>

            <!-- deprecated, use nvdCpeIndex -->
            <cpeDictionaryIndex>
              <active>false</active>
            </cpeDictionaryIndex>

            <!-- deprecated, use nvdCpeVendorProductIndex -->
            <cpeDictionaryVendorProductIndex>
              <active>false</active>
            </cpeDictionaryVendorProductIndex>
          </configuration>
        </execution>
      </executions>
    </plugin>
  </plugins>
  <!-- ... -->
</build>
```

## Resulting directory structure

When performing a full mirror without the deprecated downloads/indexes, this directory structure is created:

- download
    - certfr
    - certsei
    - cpe-dict
    - msrc
    - msrc-csv
    - nvd
- index
    - certfr-advisors
    - certsei-advisors
    - cpe-dict
    - cpe-dict-vp
    - msrc-advisors
    - msrc-kb-chains
    - msrc-products
    - nvd-cve
