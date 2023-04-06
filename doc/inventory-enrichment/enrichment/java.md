> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Inventory Enrichment](inventory-enrichment.md) >
> Java

# Java

The Java process uses the `InventoryEnrichmentPipeline` class directly. It can be used to construct a pipeline
programmatically. A full list of steps and their corresponding class names can be found [here](steps.md).

## Pipeline construction

A pipeline takes the inventory and the [mirror directory](../mirror/mirror-overview.md) as input:

```java
final File MIRROR_DIRECTORY = new File("in/mirror");
final File sourceFile = new File("in/inventory/ae-example-advisor-inventory.xls");
final Inventory inventory = new InventoryReader().readInventory(sourceFile);

final InventoryEnrichmentPipeline pipeline = new InventoryEnrichmentPipeline(inventory, MIRROR_DIRECTORY);
pipeline.setInventorySourceFile(sourceFile);
pipeline.setInventoryResultFile(new File(sourceFile.getParentFile(), "target/result.xls"));
```

The pipeline can be configured to save the intermediate steps. This is activated by default (as long as the
`inventorySourceFile` is set), and the directory defaults to
`new File(inventorySourceFile.getParentFile(), "intermediate-inventories");`

```java
pipeline.setIntermediateInventoriesDirectory(new File("target/intermediate-inventories"));
pipeline.setWriteIntermediateInventories(true);
```

Now the individual steps can be added to the pipeline. Due to several reasons, instances of the enrichers cannot be
added to the pipeline directly. Instead, the class of the enricher is added. The pipeline will manage the creation of
the enricher via reflection in a way that the pipeline can properly use it. The `addEnrichment` method returns the
created instance of the enricher, so that the configuration can be directly modified. All methods in this process follow
the builder pattern, meaning you can chain the configuration calls.

```java
pipeline.addEnrichment(ArtifactYamlEnrichment.class).getConfiguration()
        .addYamlFile(new File("in/correlation"));

pipeline.addEnrichment(VulnerabilityAssessmentDashboard.class).getConfiguration()
        .setOutputDashboardFile(new File("target/dashboard.html"))
        .setSvgDirectory(new File("target/resources/svg"))
        .setVulnerabilityTimelinesGlobalEnabled(false)
        .setInsignificantThreshold(7.0);
```

Now the pipeline can be executed:

```java
pipeline.performEnrichmentIfActive();
```

### Advanced configuration

Every `InventoryEnricherConfiguration` has multiple base properties:

- `active` (default: `true`): If set to `false`, the enricher will not be executed by the pipeline. This is also hinted
  at by the method name `performEnrichmentIfActive`. The enrichment pipeline also being an `InventoryEnricher`, it can
  also be deactivated by setting this property to `false`.
- `id`: A unique ID for this enricher. It can be used to resume the pipeline at a specific enricher. Defaults to:
  ```java
  private String buildInitialId() {
      final String id = getClass().getSimpleName().replace("Configuration", "").replace("Inventory", "");
      final String[] split = id.split("(?=[A-Z])");
      return String.join("-", split).toLowerCase();
  }
  ```

Resume at a specific enricher by setting the `resumeAt` property of the pipeline to the ID of the enricher. This will
only work if the intermediate inventory directory is set and active and the enricher has been executed on these exact
steps before.

```java
pipeline.addEnrichment(CpeDerivationEnrichment.class).getConfiguration()
        .setId("cpe-derivation");
pipeline.resumeAt("cpe-derivation");
```

## Full example

```java
final File MIRROR_DIRECTORY = new File("in/mirror");

final File sourceFile = new File("in/inventory/ae-example-advisor-inventory.xls");
final Inventory inventory = new InventoryReader().readInventory(sourceFile);

final InventoryEnrichmentPipeline pipeline = new InventoryEnrichmentPipeline(inventory, MIRROR_DIRECTORY);
pipeline.setInventorySourceFile(sourceFile);
pipeline.setInventoryResultFile(new File(sourceFile.getParentFile(), "target/result.xls"));
pipeline.setIntermediateInventoriesDirectory(new File(sourceFile.getParentFile(), "target/intermediate-inventories"));
pipeline.setWriteIntermediateInventories(true);

pipeline.addEnrichment(ArtifactYamlEnrichment.class).getConfiguration()
        .addYamlFile(new File("in/correlation"));
pipeline.addEnrichment(CpeDerivationEnrichment.class);
pipeline.addEnrichment(MsrcVulnerabilitiesByProductEnrichment.class);
pipeline.addEnrichment(NvdVulnerabilitiesFromCpeEnrichment.class);

pipeline.addEnrichment(NvdCveDetailsFillingEnrichment.class);
pipeline.addEnrichment(MsrcAdvisorFillDetailsEnrichment.class);

pipeline.addEnrichment(VulnerabilityStatusEnrichment.class).getConfiguration()
        .addStatusFile(new File("in/status"));

pipeline.addEnrichment(NvdCveDetailsFillingEnrichment.class);
pipeline.addEnrichment(MsrcAdvisorFillDetailsEnrichment.class);
pipeline.addEnrichment(CertFrAdvisorFillDetailsEnrichment.class);
pipeline.addEnrichment(CertSeiAdvisorFillDetailsEnrichment.class);

pipeline.addEnrichment(VulnerabilityAssessmentDashboard.class).getConfiguration()
        .setOutputDashboardFile(new File("target/dashboard.html"))
        .setSvgDirectory(new File("target/resources/svg"))
        .setVulnerabilityTimelinesGlobalEnabled(false)
        .setInsignificantThreshold(7.0);

pipeline.performEnrichmentIfActive();
```
