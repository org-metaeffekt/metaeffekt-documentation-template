> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > VAD Detail Levels

# Vulnerability Assessment Dashboard Detail Levels

In some cases, displaying all the information available in a dashboard can lead to the dashboard growing rapidly in
size, depending on the amount of vulnerabilities the dashboard is generated for.

To at least partially mitigate this, the dashboard can be configured to only display certain information, depending on
several factors.

## Matchers

Matchers are used to determine whether a certain detail level should be used for a vulnerability. They have the
following properties:

- `status`: a comma-separated list of vulnerability statuses that the matcher applies to. Matches if the vulnerability
  has one of the specified statuses.
- `allCpe`: a comma-separated list of CPEs that the matcher applies to. Matches if the vulnerability has all of the
  specified CPEs.
- `anyCpe`: a comma-separated list of CPEs that the matcher applies to. Matches if the vulnerability has at least one of
  the specified CPEs.
- `vulnerabilityName`: a comma-separated list of vulnerability names that the matcher applies to. Matches if the
  vulnerability has at least one of the specified names.

The matcher will only match if all of the specified properties match.

## Detail Levels

The following detail levels are available:

- `timeline`: whether the timeline should be displayed. This attribute is the main reasons the detail levels were
  introduced, as the timeline can not only take very long to generate, but also take up a lot of space in the dashboard.
- `references`: whether the vulnerability references should be displayed.
- `advisoriesGlobal`: whether advisory information should be displayed at all.
- `advisoriesReferences`: whether references in the advisory information should be displayed.
- `advisoryByTypes`: what type of advisories should be shown, whilst all others are hidden.
    - `any` (default): any advisory type.
    - comma-separated list of advisory types (notice, ...)
- `advisoryByProviders`: what provider of advisories should be shown, whilst all others are hidden.
    - `any` (default): any advisory provider.
    - comma-separated list of advisory providers (CERT-FR, GHSA, ...)
- `eolDate`: whether the EOL date information should be displayed.

## Default Detail Level

By default, all properties are set to the most detailed level, to ensure that all information is displayed.

## Creating Detail Levels

### Correlation YAML

```yaml
- affects:
    Id: linux-kernel
  append:
    VAD Detail Level Configurations: |-
      matcher:
        status = "in review, insignificant";
        allCpe = "cpe:/a:linux:linux_kernel, cpe:/o:linux:linux_kernel";
        anyCpe = "cpe:/a:linux:linux_kernel, cpe:/a:linux_test:linux_kernel";
        vulnerabilityName = "CVE-2023-35829, CVE-2023-35828, CVE-1999-0431";
      detail:
        timeline = "false";
        advisoriesGlobal = "false";
      matcher: status = "in review, insignificant"
      detail: timeline = "false"
```

The detail level information is appended to artifacts in the `VAD Detail Level Configurations` field. This field
contains a custom format:

- `matcher`: the matcher information, as described above.
- `detail`: the detail level information, as described above.

Each of these two sections contains information in the following format: `key = "value";` (a key-value pair), where the
key is the name of the property, and the value is the value of the property. The value is a string, and must be enclosed
in double quotes.

The newlines are optional, but make the configuration easier to read. The last semicolon is optional as well.

If multiple detail levels are specified, the individual detail levels must be separated by a newline.

### VAD Configuration

```xml

<detailLevels>
    <map>
        <matcher>
            <status>in review, insignificant</status>
            <allCpe>cpe:/a:linux:linux_kernel, cpe:/o:linux:linux_kernel</allCpe>
            <anyCpe>cpe:/a:linux:linux_kernel, cpe:/a:linux_test:linux_kernel</anyCpe>
            <vulnerabilityName>CVE-2023-35829, CVE-2023-35828, CVE-1999-0431
            </vulnerabilityName>
        </matcher>
        <timeline>false</timeline>
        <references>true</references>
        <advisoriesGlobal>true</advisoriesGlobal>
        <advisoriesReferences>true</advisoriesReferences>
        <advisoryByTypes>
            <entry>any</entry>
        </advisoryByTypes>
        <advisoryByProviders>
            <entry>any</entry>
        </advisoryByProviders>
        <eolDate>true</eolDate>
    </map>
</detailLevels>
```

The Vulnerability Assessment Dashboard configuration contains a `detailLevels` section, which is a map of detail levels.
Just like the correlation YAML, each detail level contains a `matcher` section, but the `detail` section is replaced by
the individual properties.
