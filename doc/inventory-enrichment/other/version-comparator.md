> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > Version Comparator

# Version Comparator

<!-- TOC -->

* [Version Comparator](#version-comparator)
    * [Introduction](#introduction)
    * [Concept](#concept)
        * [Tokenizer](#tokenizer)
        * [Categorization](#categorization)
        * [Comparing](#comparing)
    * [Curation format](#curation-format)

<!-- TOC -->

## Introduction

The world of version numbers is far from uniform. It's a landscape filled with a many different formats, many of which
stray from the simplicity of semantic versions or easily readable structures. This complexity can sometimes pose a
challenge even for humans. Try, for instance, the task of ordering the following versions:

```
2.616.rev.20171103
dh_nvr5464_eng_p_v2.616.0000.0.r.20171102
2.615
2.616.0000.0.r.20171101
```

<details>
<summary>Solution</summary>

```
2.615
2.616.0000.0.r.20171101
dh_nvr5464_eng_p_v2.616.0000.0.r.20171102
2.616.rev.20171103
```

</details>

The ability to compare version numbers is a fundamental requirement in vulnerability correlation. Without the capability
to tell whether a version is greater or lesser than another, it becomes impossible to accurately determine if a
specific vulnerability applies to a given version of a software component.

In our previous version comparator, we used a straightforward approach: extract the first semantic version found in a
version string and use that for comparison. This method effectively handled most of the cases. However, it had its
limitations, particularly when it came to version strings that included modifiers such as `update` or `beta` or firmware
versions. These elements were largely ignored, leading to inaccuracies in some instances. Recognizing this, we needed to
develop a more robust solution.

## Concept

The new version comparator follows many steps to extract relevant parts from a version. I will use the following
versions as examples throughout this process:

```
2.0.0ubuntu0
1.0.0-beta.11
8.2.2_t1a
7.0U2a-17867351
1.0.3-0.20200308084313-2adbaa4891b9
```

### Tokenizer

The only way to being able to detect versions in any format is to separate the individual components the version string
is made up of into multiple tokens, that each represent some part of the version.

Before doing that, some normalization steps are applied, like removing git hashes from the end of the string:

```
1.0.3-0.20200308084313-2adbaa4891b9
1.0.3-0.20200308084313
```

Then, a basic string tokenization is applied that segments the string at separators (`-`) or character type changes
(letter --> number, ...). Numbers joined by dots (`.`) are joined back together into a single token, however (semantic
versions).

```
[2.0.0, ubuntu, 0]
[1.0.0, -, beta, ., 11]
[8.2.2, _, t, 1, a]
[7.0, U, 2, a, -, 17867351]
[1.0.3, -, 0.20200308084313]
```

Some more terminology that is used in the following chapters:

- `version modifiers` are the parts of a version that indicate where a version is currently located in its release
  cycle, so: `beta`, `update`, `revision`, ...  
  These parts can have string/number comparable tokens behind them, which should be joined to the modifier (`update 2`).
- `string/number comparable tokens` are tokens that are either semantic versions, numbers or string sequences with the
  length 1 or 2. These are usually the tokens that interest us.
- `separators` simple strings like `.`, `_`, `-`. These are filtered out later.

Then, some more rules are applied:

- remove leading string tokens
- detect version modifiers with their extending tokens behind them
- filter out all separators
- join subsequent version modifiers into a single version modifier
- ... (some more)

And we reach this much better readable format:

```
[2.0.0, ubuntu, 0]
[1.0.0, beta 11]
[8.2.2, trial 1 a]
[7.0, update 2 a, 17867351]
[1.0.3, 0.20200308084313]
```

This is all the tokenizer does, the rest will depend on the implementation of the version class. There is only one of
these implementations currently active, so this process will be described next.

### Categorization

The `CuratedCategoriesVersionImpl` then takes these token lists and attempts to populate them into six categories.
The order of these categories is significant as it determines the order of comparison during the version comparison
process later.

- The `specVersion` is only used if there are too many parts in the version and is compared first.
- The `semVersion` category is used for semantic versions, which follow the format MAJOR.MINOR.PATCH (e.g., 2.0.0).
  This part will most likely always be populated.
- `buildVersion`
- `otherVersionPart`
- The `versionModifier` category is used for the first version modifier occurring.
- The `afterAllPart` category is used for storing parts after the version modifier to prevent them matching before it.

1. Initial Filtering: The algorithm starts by filtering out tokens that are unlikely to be relevant for version
   comparison. For example, single-character strings at the beginning of the token list are ignored.
2. Version Modifier Detection: The algorithm then looks for version modifier tokens. If a version modifier token is
   found and the `versionModifier` category is currently null, the token is assigned to the `versionModifier` category.
3. Token Categorization: The algorithm then iterates over the remaining tokens. If a token is comparable by string
   (i.e., it's a semantic version, a number, or a short string sequence), it's assigned to the first null category among
   `specVersion`, `semVersion`, `buildVersion`, and `otherVersionPart`, in that order. If the `versionModifier` category
   is not null and the `afterAllPart` category is null, the token is assigned to the `afterAllPart` category.
4. Version Part Rearrangement: After all tokens have been assigned, the algorithm checks if any rearrangement of the
   version parts is necessary. For example, if the `specVersion` category is null and the `semVersion` category contains
   a number or a semantic version, the version parts are shifted back one category. This ensures that the most
   significant version information is prioritized.
5. Special Cases: The algorithm also handles several special cases to improve the accuracy of the categorization
   process. For example, if the `buildVersion` category contains a long string (8 characters or more) without a dot,
   it's moved to the `otherVersionPart` category. If the `semVersion` category contains a 4-part dot-separated version
   and the `buildVersion` category is null, the last part of the `semVersion` is moved to the `buildVersion` category.
6. Finalization: Finally, if the `versionModifier` category is still null after all tokens have been processed, it's
   assigned a neutral token with a matching value of 0. The categorized version parts are then stored for later use in
   version comparison.

After step 2:

```
spec:2.0.0  sem:0                 build:null  other:null  mod:null        after-all:null
spec:1.0.0  sem:null              build:null  other:null  mod:beta 11     after-all:null
spec:8.2.2  sem:null              build:null  other:null  mod:trial 1 a   after-all:null
spec:7.0    sem:null              build:null  other:null  mod:update 2 a  after-all:17867351
spec:1.0.3  sem:0.20200308084313  build:null  other:null  mod:null        after-all:null
```

After step 6:

```
spec:null  sem:2.0.0  build:0                 other:null  mod:neutral_token  after-all:null
spec:null  sem:1.0.0  build:null              other:null  mod:beta 11        after-all:null
spec:null  sem:8.2.2  build:null              other:null  mod:trial 1 a      after-all:null
spec:null  sem:7.0    build:null              other:null  mod:update 2 a     after-all:17867351
spec:null  sem:1.0.3  build:0.20200308084313  other:null  mod:neutral_token  after-all:null
```

Using this, we can now compare the versions.

### Comparing

The actual comparison is then fairly simple. The algorithm iterates over the categories in order and compares the
version parts in each category. If the version parts are equal, the algorithm moves on to the next category. If the
version parts are not equal, the algorithm returns the result of the comparison. If the algorithm reaches the end of the
categories without finding any differences, the versions are considered equal.

Version modifiers are compared by their position in the version modifier hierarchy. For example, `alpha` is considered
less than `beta`, which is considered less than `rc`, and so on. To accommodate for the difference between modifiers
that come before and after the neutral version (without modifier), the algorithm assigns a negative value to modifiers
that come before the neutral version and a positive value to modifiers that come after the neutral version.

## Curation format

But, as you might expect, not every version is automatically parsable. For example, the version
`dh_nvr5464_eng_p_v2.616.0000.0.r.20171102` from the introduction above contains an unrelated number `5464` before the
relevant parts later. There is no way to know if this number is relevant or not, so it's not possible to parse this
version correctly _automatically_. This is where the curation format comes in.

This format allows for specifying rules that can be applied to a version before parsing or even completely replacing the
parsing process. The format is a simple YAML file that contains a list of rules. Here are two examples:

```yaml
# version: dh_nvr5464_eng_p_v3.616.0000.0.r.20171000
#   preprocessor: v3.616.0000.0.r.20171000
- pattern: .*?dh_nvr__NUMBER___eng_p_(.+)
  pattern-flags: i
  type: preprocessor
  segments:
    preprocessor: $1

# version: 2018w20.3-162732p
#   sem: 2018.20.3
#   build: 162732
- pattern: .*?(__YEAR__)w(__SEMVER__)-(__NUMBER__).*
  pattern-flags: i
  segments:
    sem: $1.$2
    build: $3
```

Each rule must have a `pattern` and `segments`. The `pattern` is a regular expression that is matched against the
version string. Depending on the `type` of the rule, the `segments` are evaluated differently, but all of them are a
regular expression replacement string. The `pattern-flags` are optional and can be used to specify regular expression
flags.

Types:

- `preprocessor`: The `segments` only have one key, `preprocessor`, which is a string that replaces the version string
  before parsing. This is useful when only a small part of the version string is actually relevant for comparison, but
  the version still comes in different formats, so you just help the algorithm a bit and then leave it to do the rest.
- `full`: This is the default type. The `segments` are evaluated as a regular expression replacement string. The
  replacement string can contain references to capture groups in the `pattern` using `$1`, `$2`, etc. You can set all
  version fields using `spec`, `sem`, `build`, `other`, `modifier`, and `after-all`.

These files can be specified in the `curatedVersionFiles` file list property of the `enrich-inventory` goal. There is
also an integrated list of curated versions that is used by default.
