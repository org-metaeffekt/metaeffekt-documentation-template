> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Data Sources Explained](../inventory-enrichment-overview.md) >
> EOL Date Data

# EOL Date Data

References:

- [https://endoflife.date](https://endoflife.date)
- [https://endoflife.date/docs/api](https://endoflife.date/docs/api)
- [https://github.com/endoflife-date/endoflife.date](https://github.com/endoflife-date/endoflife.date)

The EOL Date Data source contains information on when a specific version of a package, software or device will reach its
end of life, i.e. when it will no longer be supported by the vendor. We use this data on artifact level to determine
how long the artifact will be supported or if it is already unsupported.

The following chapters will explain how the data from the API is structured and how it can be used.

<!-- TOC -->
* [EOL Date Data](#eol-date-data)
  * [API](#api)
  * [Data Structure](#data-structure)
  * [Using the data](#using-the-data)
    * [Finding the current cycle of an artifact](#finding-the-current-cycle-of-an-artifact)
    * [Using the cycle to find useful information](#using-the-cycle-to-find-useful-information)
    * [Interpreting the data](#interpreting-the-data)
      * [Scenario 1: Extended Support is Available](#scenario-1-extended-support-is-available)
      * [Scenario 2: Extended Support is Not Available](#scenario-2-extended-support-is-not-available)
<!-- TOC -->

## API

The base URL of the API we use is [https://endoflife.date](https://endoflife.date). The two endpoints that are
relevant for us are:

- `/api/all.json`
- `/api/{product}.json`

The `all` endpoint returns a list of all products that are available in the API. These products serve as keys for the
`{product}` endpoint. The `{product}` endpoint returns a list of all version cycles of the product. This data is
explained in the next chapter.

## Data Structure

An example for the `java` product:

```json
[
  {
    "cycle": "20",
    "releaseDate": "2023-03-21",
    "support": "2023-09-19",
    "eol": "2023-09-19",
    "latest": "20.0.1",
    "latestReleaseDate": "2023-04-18",
    "link": "https://www.oracle.com/java/technologies/javase/20-relnote-issues.html",
    "lts": false
  },
  {
    "cycle": "19",
    "releaseDate": "2022-09-20",
    "support": "2023-03-21",
    "eol": "2023-03-21",
    "latest": "19.0.2",
    "latestReleaseDate": "2023-01-17",
    "lts": false
  },
  ...
]
```

The data is structured as an array of objects. Each object represents a version cycle of the product. The following
fields are (not always) available.

If dates are specified, they are provided in the format `YYYY-MM-DD`.

### product

This is a dynamic field that our process adds based on the product that is being processed. It is not part of the
original data. It is used to efficiently filter the data for the product using a lucene index.

### cycle

The release cycle of the version. This can be either:

- in the most cases, this is only the major part of the version number (e.g. `20` for `20.0.1`)
- sometimes it contains more than one version part
- sometimes it is a string (e.g. `pc.2020.9` or `Galaxy J1 Ace`), which cannot be used by our process unless the version
  fully matches the version of the artifact, which would have to be set manually, so in most cases we cannot use this
  data

### releaseDate

The release date for the first version in the cycle.

### latest

The latest version in the cycle.

### latestReleaseDate

The release date for the latest version in the cycle.

### link

A link to either release notes, the product page or the vendor's website. This link may be procedurally generated, like
on the `rabbitmq` product:

- `https://github.com/rabbitmq/rabbitmq-server/releases/tag/rabbitmq_v{{'__LATEST__'|replace:'.','_'}}`
- `https://archive.apache.org/dist/kafka/__LATEST__/RELEASE_NOTES.html`

- `OS X __RELEASE_CYCLE__ (__CODENAME__)`

TODO: Find all functions and write a resolver for them to generate the true link. Fields with `__XX__`? Functions with
`{{ }}`?

### eol

`string<date>` or `boolean`

- if boolean: `true` means it has reached the end of life state, without a specific date and `false` means that the end
  of life state has not been set yet
- if date: the release reaches the end of life state on this date, which can be a date in the past or in the future

### lts

`string<date>` or `boolean`

Similar to `eol`, but for when/if long term support is available for the version.

- if boolean: `true` means it has long term support and `false` means that lts is most likely never going to be
  available for this version
- if date: the cycle enters long term support on this date, which can be a date in the past or in the future

### discontinued

`string<date>` or `boolean`

Similar to `eol`, but for when/if the version is discontinued.

- if boolean: `true` means it has been discontinued and `false` means that the version is not discontinued
- if date: the cycle is discontinued on this date, which can be a date in the past or in the future

### support

`string<date>` or `boolean` or `null`

Similar to `eol`, but for when/if the version still provides support by the vendor.

- if boolean: `true` means it is still supported and `false` means that the version is not supported anymore
- if date: the cycle is still supported up till this date, which can be a date in the past or in the future
- if `null`: inverted `eol` field, meaning that if the product is not end of life, it is still supported (see rabbitmq
  below for example)

```json
{
  "product": "rabbitmq",
  "eol": "2023-12-31",
  "extendedSupport": "2024-07-31"
}
```

Note that the extended support may differ from the support date, and that there is no support date specified. This means
that the product ends support on the `2023-12-31` and that extended support is available until `2024-07-31`.

### extendedSupport

`string<date>` or `boolean` or `null`

Similar to `support`, but for when/if the version still provides extended support by the vendor.

- if boolean: `true` means it is still supported and `false` means that the version is not supported anymore
- if date: the cycle is still supported up till this date, which can be a date in the past or in the future
- if `null`: see below

[https://endoflife.date/almalinux](https://endoflife.date/almalinux):

```json
{
  "product": "almalinux",
  "cycle": "9",
  "eol": "2032-05-31",
  "support": "2027-05-31"
}
```

Meaning that security support ends on 31 May 2032 (`eol`), the same date as the end of life for AlmaLinux 9. The end of
the regular support period is 31 May 2027 (`support`).

There is another case, however:

[https://endoflife.date/samsung-mobile](https://endoflife.date/samsung-mobile)

```json
{
  "product": "samsung-mobile",
  "cycle": "Galaxy A8s",
  "eol": "false",
  "support": "false"
}
```

Which the EOL Date page interprets as `Yes`. This is because the `eol` and `support` fields are `false`, which means
that the product is not supported by regular support, but the EOL has not been reached yet, so the extended support is
still available.

On the same product, there is another example where the `eol` field is set to a date and the support is `false`. In this
case, too, the extended support uses the `eol` date:

```json
{
  "product": "samsung-mobile",
  "cycle": "Galaxy A2 Core",
  "eol": "2021-10-01",
  "support": "false"
}
```

### technicalGuidance

`string<date>`

The date on which technical guidance ends for the product. This is not the same as the end of life date, but the date
on which the vendor stops providing technical guidance for the product.

### supportedPhpVersions

As of writing this document, the `supportedPhpVersions` field is only used by the `magento` and `laravel` products. It
is a csv list of versions, with each version entry either being a single version or version range:

`7.3 - 8.1, 7.3, 7.4`

This field is currently unused, but logic for checking if a version is included is present.

### supportedPHPVersions

Duplicate key of `supportedPhpVersions`. Our process normalizes this to the `supportedPhpVersions` key, but will include
both keys in the output JSON and Documents.

### latestJdkVersion

This is the version of the Java Development Kit (JDK) for the given product cycle that has to be used to run the
product.

Example: [https://endoflife.date/azul-zulu](https://endoflife.date/azul-zulu)

### upgradeVersion

Currently, only the [amazon-neptune](https://endoflife.date/amazon-neptune) product uses this field. In this one case,
it is a string containing the version that the product will automatically be upgraded to during a maintenance window.

### releaseLabel

Contains a formatted name for the release. May contain HTML content and the same expression evaluator as the `link` key.
Examples:

- `AMI 2016.03`
- `Core __RELEASE_CYCLE__`
- `OS X __RELEASE_CYCLE__ (__CODENAME__)`
- `9 (<abbr title='Short Term Support'>STS<\/abbr>)`

### supportedKubernetesVersions

The same as `supportedPhpVersions`, but for Kubernetes versions.

### supportedJavaVersions

The same as `supportedPhpVersions`, but for Java versions.

### minRubyVersion

Only used by the [jekyll](https://endoflife.date/jekyll) product. The minimum Ruby version required to run the product.
Examples: `2.5+`, `1.9.3+`

### minJavaVersion

The same as `minRubyVersion`, but for Java versions. Only used by the [tomcat](https://endoflife.date/tomcat) product.

### codename

An alternate (project internal) name for the version. Example is android with their dessert names:

```json
{
  "product": "android",
  "codename": "Queen Cake",
  "cycle": "10"
}
```

## Using the data

### Finding the current cycle of an artifact

We use a field `EOL Id` on our Artifacts in the Inventory, that represents a product from the EOL Date data. This field
is used to find the lifecycle (all cycles) of the product. Next, the artifact version is used to find the exact cycle
the artifact is in.

Currently, a very basic algorithm is used to find the cycle:

- check if the version is the latest version of the cycle
- check if the version starts with the cycle name

### Using the cycle to find useful information

We now have a cycle, that we can use to derive a wide variety of different states and times. The following is an example
of what could be derived from an angular 15 cycle, where `Long.MAX_VALUE` (`9223372036854775807`) is used to represent
unknown times. The example data uses `2023-07-04` as the current date for calculating relative times. The artifact used
is `angular 15.2.9`.

Additionally, to the data from the API, a few other fields are added:

```json
{
  "artifact": {
    "id": "angular-15.2.9",
    "version": "15.2.9"
  },
  "cycle": {
    "product": "angular",
    "eol": "2024-05-18",
    "releaseDate": "2022-11-16",
    "lts": "2023-05-03",
    "cycle": "15",
    "support": "2023-05-03",
    "latestReleaseDate": "2023-05-03",
    "latest": "15.2.9"
  },
  "eol": {
    "date": "2024-05-18",
    "millisTillEol": 27561600000,
    "active": false,
    "state": "UPCOMING_EOL_DATE",
    "formattedMillisTillEol": "in 10 months and 1 week"
  },
  "support": {
    "date": "2023-05-03",
    "millisTillSupportEnd": -5356800000,
    "formattedMillisTillSupportEnd": "2 months ago",
    "active": false,
    "state": "SUPPORT_END_DATE_REACHED"
  },
  "extendedSupport": {
    "date": "2024-05-18",
    "formattedMillisTillExtendedSupportEnd": "in 10 months and 1 week",
    "active": true,
    "state": "UPCOMING_SUPPORT_END_DATE",
    "millisTillExtendedSupportEnd": 27561600000
  },
  "lts": {
    "date": "2023-05-03",
    "formattedMillisTillLts": "2 months ago",
    "millisTillLts": -5356800000,
    "active": true,
    "state": "LTS_DATE_REACHED"
  },
  "discontinued": {
    "millisTillDiscontinued": 9223372036854775807,
    "formattedMillisTillDiscontinued": "never",
    "active": false,
    "state": "NOT_DISCONTINUED"
  },
  "technicalGuidance": {
    "active": false,
    "state": "NO_TECHNICAL_GUIDANCE",
    "millisTillTechnicalGuidanceEnd": 9223372036854775807,
    "formattedMillisTillTechnicalGuidanceEnd": "never"
  },
  "state": {
    "scenario": "extendedSupportInformationPresent",
    "extendedSupportAvailable": {
      "key": "extendedSupportValid"
      "rating": 3
    }
  },
  "versionRecommendation": {
    "lifecycle": {
      "alreadyActive": false,
      "latest": "16.1.3"
    },
    "cycle": {
      "alreadyActive": true,
      "latest": "15.2.9"
    },
    "nextSupportedExtended": "14.3.0",
    "nextSupported": "16.1.3"
  }
}
```

### Interpreting the data

The 6 values we use from the data source can either be a Boolean or a date:

- EOL (End of Life): Generally, whether something has reached the end-of-life state, i.e., both support and extended
  support have expired.
- Support: Whether the basic support is still valid.
- Extended Support: Something like security support or similar, is usually either not set or equals the EOL date.
- LTS (Long Term Support): If Boolean, whether the cycle is LTS; if Date, when the cycle becomes LTS.
- Discontinued: Whether the cycle is explicitly marked as discontinued, is often not set.
- Technical Guidance: When the technical guidance support ends, is often not set.

If the value is a date, it always indicates when this state will be reached. Except for LTS, reaching this date is
always something negative.

We can differentiate the lifecycle state of a product based on whether extended support differs from the regular
support (is available) or not. Here are the two scenarios with all their phases of development:

#### Scenario 1: Extended Support is Available

> 1. EOL has not been reached, both support and extended support are still valid. (`supportValid`)
> 2. Support ends in less than X months (configurable, default is 6 months). (`supportEndingSoon`)
> 3. Support is no longer valid, but extended support is still in effect. (`extendedSupportValid`)
> 4. Extended support ends in less than X months (configurable, default is 6 months). (`extendedSupportEnding`)
> 5. EOL has been reached, extended support is no longer valid. (`extendedSupportExpired`)

#### Scenario 2: Extended Support is Not Available

In this case, phases 3 and 4 are skipped and the cycle immediately reaches the end of life.

> 1. EOL has not been reached, support is still valid. (`supportValid`)
> 2. Support ends in less than X months (configurable, default is 6 months). (`supportEndingSoon`)
> 3. EOL has been reached, support is no longer valid. (`supportExpired`)

This rating can be found above in the `state` field. The `scenario` field is used to determine which of the two
scenarios is used. The `key` field is used to determine which of the 5 states is active. The `rating` field is used to
determine the severity/color of the state in five steps: 1 to 5, where 1 is the best and 5 is the worst.
