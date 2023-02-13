# Data sources mirror overview

The purpose of the data mirror is to download data (JSON, XML, ...) from a variety of sources into a local directory and
create an index using Lucene Index from it. The index makes it easy to quickly search for data when it's needed during
the enrichment process.

The data is stored in a base directory, divided into two subdirectories named `download` and `index`. When initiating or
accessing a download/index, only the base directory needs to be defined as the normalized subdirectories are
automatically inferred and created.

This diagram shows the data flow in between the different Mirror phases:

![mirror overview process image](mirror-documentation-overview.svg)

## Download

Every download data source in encapsulated in a single class that extends `Download`. The downloaded files are stored in
`<BASE DIR>/download/<DOWNLOAD NAME>`. The individual downloader manages the internal structure of the download by
itself.

When a download is asked to initialize/update the downloaded data, it will only do so if one of these criteria is met:

- if the download is not yet present at all
- if the last update is further back than a specified time (default: 1 day)
- if the remote datasets have changed since the last update, this is different from download to download

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
- if the download is required: perform the individual download step from the downloader
- unlock the directory

Some more information:

- downloading data may sometimes fail due to service unavailability or network issues. To mitigate this, the process
  will retry requests a few times before finally failing. Although the mirroring process will continue, the failed
  download will be marked as broken. This allows the index structures to detect and skip the indexing of broken
  downloads.
- some requests to the data sources can be parallelized, as the data downloaded has to be processed and more requests
  can be made during that time. The individual process can define how many threads should be launched in parallel, with
  a maximum of the amount of cores available.

A full list of all download processes can be found in [dowmload.md](dowmload.md).

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

## Index

Every index in encapsulated within a single class that extends `Index`. The index files are stored in
`<BASE DIR>/index/<INDEX NAME>`.

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

A full list of all index processes can be found in [index.md](index.md).

## Examples

- Java:
  ```java
  new CertSeiDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
  new CertFrDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
  new CpeDictionaryDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
  new NvdDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
  new MsrcDownload(MIRROR_DIRECTORY).performDownloadIfRequired();
  
  new CertSeiAdvisorIndex(MIRROR_DIRECTORY).createIndexIfRequired();
  new CertFrAdvisorIndex(MIRROR_DIRECTORY).createIndexIfRequired();
  new CpeDictionaryIndex(MIRROR_DIRECTORY).createIndexIfRequired();
  new CpeDictionaryVendorProductIndex(MIRROR_DIRECTORY).createIndexIfRequired();
  new MsrcProductIndex(MIRROR_DIRECTORY).createIndexIfRequired();
  new MsrcAdvisorIndex(MIRROR_DIRECTORY).createIndexIfRequired();
  new MsrcKbChainIndex(MIRROR_DIRECTORY).createIndexIfRequired();
  new NvdVulnerabilityIndex(MIRROR_DIRECTORY).createIndexIfRequired();
  ```

- Maven:  
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