> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > GHSA Advisory Data

# GHSA Advisory Data

The GHSA Advisory Data is a data source that is used by the inventory enrichment process to derive vulnerability
information for artifacts.

The advisories reference packages from different ecosystems, which include:

- Maven (Java)
- npm (JavaScript)
- RubyGems (Ruby)
- PyPI (Python)
- Packagist (PHP)
- GitHub Actions
- purl-type:swift (Swift) (not searchable via Web-Ui)
- Go
- Hex (Erlang)
- crates.io (Rust)
- Pub (Dart)
- NuGet (.NET)

Each advisory may reference one or more packages from these ecosystems.

@formatter:off
```json
"affected": [
  {
    "package": {
      "ecosystem": "Packagist",
      "name": "francoisjacquet/rosariosis"
    },
    "ranges": [
      {
        "type": "ECOSYSTEM",
        "events": [
          {
            "introduced": "0"
          },
          {
            "fixed": "8.9.3"
          }
        ]
      }
    ]
  }
]
```
@formatter:on

There are multiple different `events` that are parsed into our data model of `VulnerableSoftwareVersionRangeEcosystem`s:

- `introduced`: Version Start Including
- `fixed`: Version End Excluding
- `last_affected`: Version End Including

Together with those version ranges, the package name and ecosystem can be used to match advisories (and their referenced
CVE) to artifacts.

There are two use-cases where this data can be used that will be explained below.

## CVE to Advisories

This use-case is relatively easy to implement and resembles the one of other advisors. This is done by the
`ghsaAdvisorFillDetailsEnrichment`, which will check for any GHSA entries that reference the CVE of interest and adding
it to the inventory. This enricher also adds all the relevant advisor data to the vulnerability.

## Artifacts to Advisories to CVE

To find the advisories that match an artifact, the `affected` information from the advisories is used. Depending on the
ecosystem, a different `GhsaArtifactVulnerabilityMatcher` as specified in `GhsaEcosystem` is used.

They all work very similarly, they always take some attributes that the artifact has and perform a query on the index
using it.

@formatter:off
```java
final String artifactId = normalizeArtifactId(artifact.getId());
final String groupId = artifact.getGroupId();
final String version = artifact.getVersion();

return super.ghsaQuery.findByVsMaven(groupId, artifactId, version, super.githubReviewed);
```
@formatter:on

The index will only be using the advisories that are from that ecosystem and will check for the version range. Depending
on what matcher is used, different attributes and normalization strategies will be used.

Then, all CVEs referenced by the advisories are added to the artifact.
