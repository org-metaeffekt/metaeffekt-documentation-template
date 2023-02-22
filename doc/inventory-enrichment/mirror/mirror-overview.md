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

```
new CertSeiDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
new CertFrDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
new CpeDictionaryDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
new NvdDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
new MsrcDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
new MsrcManualCsvDownload(MIRROR_DIRECTORY).performDownloadIfRequired(); // manual download

new CertSeiAdvisorIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new CertFrAdvisorIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new CpeDictionaryIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new CpeDictionaryVendorProductIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new MsrcProductIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new MsrcAdvisorIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new MsrcKbChainIndex(MIRROR_DIRECTORY).createIndexIfRequired();
new NvdVulnerabilityIndex(MIRROR_DIRECTORY).createIndexIfRequired();
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

            <msrcDownload/>
            <msrcCsvDownload/>
            <cpeDictionaryDownload/>
            <certSeiDownload/>
            <certFrDownload/>
            <!-- is deprecated, will stop working at the end of 2023 -->
            <nvdLegacyDownload/>
            <!-- you will need an API key in order to download the NVD data:
                 https://nvd.nist.gov/developers/request-an-api-key
                 more information: https://nvd.nist.gov/developers/start-here -->
            <nvdCveDownload>
              <active>false</active>
              <apiKey></apiKey>
            </nvdCveDownload>

            <certSeiAdvisorIndex/>
            <certFrAdvisorIndex/>
            <cpeDictionaryIndex/>
            <cpeDictionaryVendorProductIndex/>
            <msrcProductIndex/>
            <msrcAdvisorIndex/>
            <msrcKbChainIndex>
              <msrcUpdateGuideDownloadCsvFiles>
                <!--<file></file>-->
              </msrcUpdateGuideDownloadCsvFiles>
            </msrcKbChainIndex>
            <nvdLegacyVulnerabilityIndex/>
            <nvdVulnerabilityIndex>
              <active>false</active>
            </nvdVulnerabilityIndex>
          </configuration>
        </execution>
      </executions>
    </plugin>
  </plugins>
  <!-- ... -->
</build>
```
