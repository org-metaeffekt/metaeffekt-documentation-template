> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Mirror](mirror-overview.md) > Index

# Index

TODO

<!-- TOC -->

* [Index](#index)
    * [Common steps](#common-steps)
    * [List of indexes](#list-of-indexes)

<!-- TOC -->

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

## List of indexes

TODO
