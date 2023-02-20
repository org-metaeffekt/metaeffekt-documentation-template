> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Mirror](mirror-overview.md) > Index

# Index

TODO

## Common steps

Every index in encapsulated within a single class that extends `Index`. The index files are stored in
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
- create the index:
    - assert that the required downloads and indexes exist
    - create the index documents (different from index to index)
    - if at least one document has been created, write them to the index directory
- unlock the directory

Some more information:

- the index created is a Lucene Index. Such an index contains a list of documents, where each document is a Key-Value
  Map. depending on the index, these maps can contain different data.
- indexes can depend on one or more other downloads or indexes. If an index is attempted to be created or updated while
  dependent structures are not present, the index will be aborted.

A full list of all index processes can be found [below](#list-of-indexes).

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

## List of indexes

TODO
