> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Inventory Enrichment](inventory-enrichment.md) >
> [Inventory Enrichment Steps](steps.md) > Different CPEs in our process

# Different CPEs in our process

Within our inventories, there are several columns that may contain CPEs in a CSV format:

- `CPE URIs`
- `Derived CPE URIs`
- `Additional CPE URIs`
- `Inapplicable CPE URIs`
- `Matched CPEs`

The first four columns contain data that will later be read, while the `Matched CPEs` column is used only for
documentation purposes.

`Derived CPE URIs` are the CPEs that are derived from the artifact data by our
algorithm ([CPE Derivation](steps.md#cpe-derivation)). However, these CPEs are not always accurate due to false
positives or missing information, which is why, in most cases, they need to manually be adjusted. This is where
our [correlation-yaml format](artifact-correlation.md) comes into play, allowing us to set or delete attributes on
artifacts. In this step, typically only the`Additional CPE URIs` and `Inapplicable CPE URIs` fields are set. Previously,
we also set the `CPE URIs` field, but we have since stopped doing so for reasons that will become clear.

## Effective CPE

This data becomes relevant in e.g. [CPE to CVE](steps.md#nvd-cve-from-cpe) correlation steps, where the effective CPEs
are calculated, but not stored in the inventory. In pseudocode, this process works as follows:

```
Effective CPE = isset(CPE URIs) ? (CPE URIs) : ((Derived CPE URIs + Additional CPE URIs) - Inapplicable CPE URIs)
```

Essentially, the `Derived`, `Additional`, and `Ignored CPEs` are ignored as soon as at least one CPE is set in the
`CPE URIs` field. Otherwise, the `Derived` and `Additional CPEs` are collected, and the `Inapplicable` ones are
subtracted. After this, a filtering action is performed to remove duplicates and reorder the CPE, but this only becomes
relevant in some special cases.

This is also why we no longer use the `CPE URIs` field: _it overwrites all other fields_. If our algorithm finds
new/different `Derived CPEs` that were not considered before (via new information, improved data from sources, improved
matching algorithm, ...), these new ones will be completely ignored. This would be critical if this new information
had led to a better automatic result. This is why, in the [Artifact YAML Correlation](artifact-correlation.md) guide, we
discourage the usage of the `CPE URIs` field and instead recommend using the
`Additional CPE URIs`/`Inapplicable CPE URIs` fields.

In any case, the Effective CPE can now be used for correlating vulnerabilities.
