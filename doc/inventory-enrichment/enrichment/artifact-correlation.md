> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > Artifact Correlation

# Vulnerability Assessment (Correlation)

## Introduction

This document describes best practices and tips/tricks on how to best create and maintain correlation files, as used by
the [Artifact Correlation YAML](steps.md#artifact-correlation-yaml) enrichment step.

Automatic vulnerability correlation, as provided by the [CPE Derivation step](steps.md#cpe-derivation), can sometimes be
incorrect due to incomplete, ambiguous, or incorrect information provided by the artifacts in an inventory. This makes
manual interference necessary to ensure that accurate CPE information is specified for each artifact.

Artifact correlation files contain CPE and other vulnerability-related information, such as KB identifiers for
the [MSRC Vulnerabilities from Products](steps.md#msrc-vulnerabilities-from-ms-products). These files allow users to
specify additional CPEs or remove incorrect ones, improving on the accuracy of automatic correlation.

This document will focus on the CPE correlation aspect, not the Microsoft vulnerability information.

## Correlation loop

Preparation:

- Create a YAML file where the correlation entries will be stored in
- Open the file in your preferred editor. You can specify the [artifact-data.json](example-data/artifact-data.json)
  JSON schema to enable guided assistance when it comes to format and attributes.
- Create an [inventory enrichment pipeline](steps.md) using (at least) these steps:
    - `artifactYamlEnrichment`: This step will read the correlation file and add the information to the inventory.
    - `cpeDerivationEnrichment`: This step will automatically derive CPE information for each artifact.
    - optional: `nvdMatchCveFromCpeEnrichment`: Finds vulnerabilities that match the CPEs of the artifacts.
    - optional: `nvdCveFillDetailsEnrichment`: Adds NVD CVE information to the matched vulnerabilities.

Correlation loop:

- Run the pipeline on the inventory.
- For each artifact in the inventory, use the [steps listed below](#initial-state) to determine if the CPE information
  is incorrect or incomplete and adjust the correlation file accordingly.

Sometimes, multiple loops are required to check whether the effective CPE information matches the expected information.
Maybe a mistake has been made, where an incorrect field was listed, or the CPE was misspelled? This has all happened
before.

If you have access to the source code of the _metaeffekt Artifact Analysis_ project, you can head down to the
[Utility Class](#utility-class) section, to learn more about how to easily iterate over artifacts in an inventory with
automatic suggestions and other features.

## Writing a correlation file (+ best practices)

### Initial state

No matter if an artifact has or does not have derived CPE, it should always be analyzed by hand once more to confirm
that the automatic derivation is correct. An artifact can be in multiple different states:

- No matched CPE URIs in the `Derived CPE URIs` field:  
  Check whether there truly are no more entries by checking the internet for CPE on the artifact `Id`/...
- Matched CPE URIs in the `Derived CPE URIs` field:  
  Check all matched CPE URIs and determine whether they are correct or not. If they are not, remove them from the
  artifact by adding them to the `Inapplicable CPE URIs` field. If they are correct, add them to the
  `Additional CPE URIs` field.

### Creating the entry

If at least one modification to the artifact is required or if a CPE URI has been correctly matched, an entry in the
YAML file has to be created. A well-formed entry is formatted as follows:

```yaml
# Id:               reactor-netty-0.8.8.RELEASE.jar
# Component:        Reactor Project
# Group Id:         io.projectreactor.netty
# Version:          0.8.8.RELEASE
# Derived CPE URIs: cpe:/a:pivotal:reactor_netty
# reason:           cpe:/a:pivotal:reactor_netty --> some reason
- affects:
    Id: reactor-netty-*.jar
  append:
    Inapplicable CPE URIs: cpe:/a:pivotal:reactor_netty
```

An entry should always include:

- the artifact data, such as `Id`, `Component`, `Group Id`, `Version` and other fields if available/useful
- the automatically derived CPE information if present
- a `reason` tag that describes why this entry is the way it is
- the actual entry in YAML format

#### Artifact Correlation Data format

The [artifact-data.json](example-data/artifact-data.json) schema file describes what format the YAML file must be in:

| Property    | Description                                                                                                                                                                                                                                               |
|-------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `affects`   | This section is mandatory: It contains either a single artifact matcher or a list of matchers, see [artifact matcher](#artifact-matcher). Artifacts have to match with at least one of these matchers in order to have the setters below applied to them. |
| `ignores`   | It contains either a single artifact matcher or a list of matchers, see [artifact matcher](#artifact-matcher). None of these may match for the entry to become active.                                                                                    |
| `append`    | CSV-append all following values to the artifact. See [Artifact appender](#artifact-appender).                                                                                                                                                             |
| `remove`    | CSV-split and remove all following values from the artifact. See [Artifact appender](#artifact-appender).                                                                                                                                                 |
| `overwrite` | Set the value of the following attributes on the artifact. See [Artifact appender](#artifact-appender).                                                                                                                                                   |
| `clear`     | Clear (empty) the following attributes. This is a list of artifact attributes.                                                                                                                                                                            |

#### Artifact matcher

An artifact matcher is a set of key-value pairs that represents artifact attributes and artifact values. An entry may
look like this:

```yaml
Id: openssl-*
Component: openssl
```

This entry uses wildcards.

| Pattern              | Description                                                                                     |
|----------------------|-------------------------------------------------------------------------------------------------|
| `*`                  | Wildcard that matches any amount of characters, is translated to a `.+` in a regular expression |
| `?`                  | Wildcard that matches exactly one character, is translated to a `.` in a regular expression     |
| `open-*-toolkit/i`   | Regular expression flags with wildcards from above                                              |
| `/open-.+-toolkit/i` | Full regular expression support                                                                 |

#### Artifact appender

When adding/removing CPEs, only the `Inapplicable CPE URIs` and `Additional CPE URIs` attributes should be used.
`CPE URIs` (sometimes with `cpe:/a:none:none`) has been used in the past, but has been considered potentially dangerous,
as it will lead to the artifact never matching with any new/other CPEs in the future. It is better to be notified of too
many vulnerabilities than too few. This means, all inapplicable CPE URIs should be listed in a comma-separated list
under `Inapplicable CPE URIs` and additional ones under `Additional CPE URIs`.

### Correctly derived CPE

When CPEs have been derived correctly by the system, an entry with the CPE should be created under
`Additional CPE URIs`. This is so that when the derivation algorithm changes in the future, be it an improvement for
reducing the amount of false positives or something else, the CPE does not disappear from the derived list.

Example:

```yaml
# Id:               slf4j-api-1.7.26.jar
# Component:        SLF4J
# Group Id:         org.slf4j
# Version:          1.7.26
# Derived CPE URIs: cpe:/a:qos:slf4j
- affects:
    Id: slf4j-api-*.jar
  append:
    Additional CPE URIs: cpe:/a:qos:slf4j
```

### Reasoning chain

As seen above, the automatically generated entry contains a reason tag: `# reason: cpe:/a:pivotal:reactor_netty -->`
This is so that when the entry is visited in the future, the reason behind the modifications can be understood. The best
practice for this is:

- one entry per line (one CPE/Artifact/…),
- a reasoning chain connected by `-->` arrows with links/text in between.

An example:

```yaml
# reason: https://people.apache.org/~germuska/struts-taglib/docs/apidocs/org/apache/struts/taglib/html/package-summary.html --> The "struts-html" tag library contains JSP custom tags useful in creating dynamic HTML user interfaces, including input forms.
#         cpe:/a:taglib:taglib --> https://taglib.org/ --> TagLib is a library for reading and editing the meta-data of severalpopular audio formats.
```

### Follow-up entries

Multiple entries can be chained together to form more of a logic than a simple entry can. See this example:

```yaml
- affects:
    - Component: Spring Security*
    - Id: spring-security-*.jar
  append:
    Additional CPE URIs: cpe:/a:pivotal_software:spring_security, cpe:/a:vmware:spring_security, cpe:/a:vmware:springsource_spring_security

- affects:
    Id: spring-security-oauth*.jar
  append:
    Additional CPE URIs: cpe:/a:pivotal_software:spring_security_oauth, cpe:/a:pivotal:spring_security_oauth
  remove:
    Additional CPE URIs: cpe:/a:pivotal_software:spring_security, cpe:/a:vmware:spring_security, cpe:/a:vmware:springsource_spring_security
```

This example shows how the first entry adds CPEs to all Spring Security artifacts, while the second entry removes the
CPEs from the OAuth artifacts. This is done by using the `Additional CPE URIs` attribute in the `append` section of the
first entry in combination with the `remove` and `append` sections of the second entry.

Be careful when creating combinations like this, as they can be hard to understand and debug for someone else, or
yourself in the future. It is recommended to create a "reason" comment for cases like this, and to group related entries
close to each other.

### Multiple entries in affects

As seen in examples above, the `affects` and `ignores` attributes can contain multiple entries by using a list of
entries, instead of a single entry. This is useful for cases where multiple artifacts should match the same entry.

### Never-correct entries (like github:github and jboss:jboss)

There are some CPEs that will most likely never be correct, like `cpe:/a:github:github` and `cpe:/a:jboss:jboss`. As
these are very common, they will be matched by the system, and will be shown as false positives. To avoid this, you
could create entries for each of the artifacts matching this CPE that remove the CPE, or you could create a single
global entry like this:

```yaml
# reason: cpe:/a:github:github never the correct CPE. Remove it from all artifacts that relate to GitHub.
- affects:
    any: "*github*/i"
  append:
    Inapplicable CPE URIs: cpe:/a:github:github
```

If it turns out to be the correct CPE after all on a selected amount of artifacts, you may re-add it to the affected
artifacts using:

```yaml
# reason: cpe:/a:github:github is the correct CPE for this artifact.
- affects:
    Id: something-github-*.jar
  remove:
    Inapplicable CPE URIs: cpe:/a:github:github
  append:
    Additional CPE URIs: cpe:/a:github:github
```

## Utility class

This section will only be useful to you, if you have access to the source code of the _metaeffekt Artifact Analysis_
project.

This command line tool will help you in the process of finding the correct CPEs for artifacts in an inventory by
suggesting URLs, searching a local vulnerability index and automatically enriching inventories.

Getting started:

- On the top-level of the project, create a file `.local-properties`:
    - Set a property `ae.mirror.path=` that specifies a directory that contains the new
      [Data Source Mirror](../mirror/mirror-overview.md) or an empty directory where the mirror will be created in.
    - Set a property `ae.mirror.nvd.apikey=` where you can enter your personal/company
      [NVD API key](../mirror/download.md#nvd-api). This is only required if you need to download the data into the
      mirror directory.
- Open the `CorrelationUtilities` class
- Add at least one path to a correlation file/directory to the list of correlation files:
  ```java
  private List<File> correlationFiles = Arrays.asList(
      new File("/Users/.../correlation-1"),
      new File("/Users/.../correlation-2"),
      ...
  );
  ```
- Run the `main` method: `public static void main(String[] args)`
- If you need to mirror the data sources, enter `Y` and confirm on this prompt:
  ```
  Do you want to perform a full mirror? [Y/n] Failed to initialize index: Index directory is empty: /Users/...
  ```
  This will trigger the download and index classes to fully update the mirror. This can take quite a while (10-20
  minutes).  
  If you ever need to update the mirror, enter `m` → `m` to update all mirrors.

The command line tool is structured using a set of different menus that can be navigated by entering short or long
identifiers of actions to perform. The short action is always highlighted in `[brackets]`, the long version is the
option, but without the brackets.

- **main menu**:
  ```
  -----------------------< Correlation Utilities >------------------------
  Options: [i]nventory, [q]uery, [e]nrichment, [c]onfig, [m]irror, [ex]it
  ```
  Seeing as this application is used on the command line, you will navigate through it using the keyboard, by entering
  the short or long identifier of the action you want to perform. The main menu offers access to all tool functions.
- **mirror `m`**:
  ```
  ----------------------------< Data Mirror >-----------------------------
  Options: [f]ull reset + mirror, [m]irror all, [d]ownload all, [i]ndex all, [a]nalyze, [b]ack, [ex]xit
  ```
  Allows for updating the local mirror. `m` is recommended, as only downloading or only indexing is no use.  
  You may use `a` to show the size and age of the mirror and `f` to fully reset the mirror, deleting all files and
  downloading and indexing all data sources again.
- **enrichment `e`**:
  ```
  ------------------------< Inventory Enrichment >------------------------
  [b]ack / [e]xit, inventory enrichment pipelines:
  - [0] correlation
  - [1] nvd
  - [2] nvd-advisors
  - [3] vad
  ```
  Allows for selecting an enrichment pipeline from (currently) four different pre-configured pipelines or a custom
  pipeline specified in
  ```java
  private final static Map<String, List<Class<? extends InventoryEnricher>>> ENRICHMENT_PIPELINES = new LinkedHashMap<String, List<Class<? extends InventoryEnricher>>>() {{
  ```
  at the bottom of the class. Depending on the pipeline, different steps will be executed. See the above-mentioned
  attribute `ENRICHMENT_PIPELINES` to see what steps will be executed.  
  After selecting the pipeline, you will be prompted to select what should be enriched:
  ```
  Enrichment mode [a]rtifact, [i]nventory, [s]tored inventory: 
  ```
  `artifact` constructs a new inventory using a cloned version of the currently selected artifact from the `[i]nventoty`
  menu and applies the enrichment. `inventory` clones the inventory and applies the enrichment. `stored inventoty` works
  a bit different and is a really useful new option: The command line tool stores these enriched inventories in the
  `target` directory and using `[sw]itch` in the `[i]nventoty` menu. You can switch between the un-enriched and enriched
  versions of the inventory. When re-applying the pipeline to the inventory using `stored inventoty`, the un-enriched
  inventory will be used, no matter what inventory is selected.
- **query `q`**:
  ```
  --------------------------< Perform Queries >---------------------------
  Options: {data query}, [h]elp, [b]ack, [e]xit
  h
  | Identifier                 | Short Identifier |
  |----------------------------|------------------|
  | cert-fr-advisor            | cf, certfr       |
  | cert-sei-advisor           | cs, certsei      |
  | msrc-advisor               | msa, msrca       |
  | msrc-product               | msp, msrcp       |
  | msrc-kb-chain              | mskb, msrckb     |
  | nvd-cpe-api                | cpe              |
  | nvd-cpe-api-vendor-product | cpevp, vp        |
  | nvd-cve                    | cve              |
  ```
  Allows for accessing the local index. Either the `Identifier` or the `Short Identifier` can be used to start a query.
  All the options may seem a bit overwhelming at first, but simply trying out the different options will guide you
  through creating a query, no need for learning all sub-options by heart. If you want, however, you can directly
  combine the follow-up questions in the initial input to skip the questions:
  ```
  cpe c wink
  
  cpe:/a:apache:wink
  cpe:/a:apache:wink:0.1
  cpe:/a:apache:wink:1.0
  cpe:/a:apache:wink:1.1.0
  cpe:/a:apache:wink:1.1.1
  cpe:/a:apache:wink:1.1.2
  cpe:/a:apache:wink:1.2.0
  cpe:/a:apache:wink:1.2.1
  cpe:/a:apache:wink:1.3.0
  ```
- **inventory `i`**:
  ```
  --------------------- original ----------------------
  Artifact index 0 of 537
  Id:        acl-2.2.53
  Component: acl
  Version:   2.2.53
  URL:       https://savannah.nongnu.org/projects/acl
  Type:      package
  -----------------------------------------------------
  Options: [go], [n]ext, [p]revious, [l]inks, [su]rrounding artifacts, [si]milar artifacts, [a]ll attributes, [ya] yaml -> artifact, [yi] yaml -> inventory, [en]rich inventory/artifact, [s|q]uery, change [source|src] inventory, [sw]itch working inventory, [cls|clear] screen, [b]ack, [ex]it
  ```
    - Whenever a dialog is done, the current artifact is printed with it's most important attributes for the artifact
      correlation. All other attributes can be printed using `[a]ll attributes`.
    - Navigate using `[n]ext`, `[p]revious` or `[go]`, after which a numeric ID or wildcard-string for an artifact ID
      can be specified (`acl-*`).
    - Surrounding or similar artifacts (by `Id`/`Component`):
      ```
      si
      
      [140] iwl100-firmware-39.31.5.1   |  152  iwl7260-firmware-25.30.13.0
       141  iwl1000-firmware-39.31.5.1  |  144  iwl2000-firmware-18.168.6.1
       142  iwl105-firmware-18.168.6.1  |  145  iwl2030-firmware-18.168.6.1
       143  iwl135-firmware-18.168.6.1  |  146  iwl3160-firmware-25.30.13.0
        77  firewalld-0.9.3             |  149  iwl6000-firmware-9.221.4.1
        78  firewalld-filesystem-0.9.3  |  148  iwl5150-firmware-8.24.2.2
       147  iwl5000-firmware-8.83.5.1_1 |  150  iwl6000g2a-firmware-18.168.6.1
       151  iwl6050-firmware-41.28.5.1  |  293  mariadb-connector-c-3.1.11
      ```
    - `[ya]`/`[yi]` will apply all correlation files to the current artifact or inventory and display the effective
      changes detected (+ consistency warnings).
    - `[sw]itch` will switch between the `stored inventory` and the original inventory.
    - `[s|q]uery` or `[en]rich` allow for accessing the other menus listed above .
