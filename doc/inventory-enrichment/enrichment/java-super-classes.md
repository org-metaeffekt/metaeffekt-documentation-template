> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Inventory Enrichment](inventory-enrichment.md) >
> Superclasses

# Superclasses

## Superclass `InventoryEnrichment`

To understand the enrichment process, the `InventoryEnrichment` class has to be understood first, even if this is not
the [Java](java.md) chapter.

Every inventory enrichment step inherits from the `InventoryEnricher` class. This class has several abstract methods
that need to be implemented:

- `getConfiguration()` - Returns the configuration for this step. Each step has its own configuration class. Considering
  that the configuration instance can be interchanged using the setter, the instance returned by this method should not
  be cached, just call it every time you need it.
- `performEnrichment(Inventory)` - This method is called to perform the actual enrichment. It takes the inventory as
  input, which it transforms in some way. As the inventory is passed by reference, no new instance needs to be returned,
  but rather the input instance is directly modified.
- `getEnrichmentName()` - Returns the name of the enrichment step. This is used for logging purposes.
- `getInventoryFileNameSuffix()` - Returns the suffix that is appended to the inventory file name when enabling
  intermediate inventory saving.

A simple example for this is the `ArtifactYamlEnrichment` class:

```java
public class ArtifactYamlEnrichment extends InventoryEnricher {

    private ArtifactYamlEnrichmentConfiguration configuration = new ArtifactYamlEnrichmentConfiguration();

    public void setConfiguration(ArtifactYamlEnrichmentConfiguration configuration) {
        this.configuration = configuration;
    }

    @Override
    public ArtifactYamlEnrichmentConfiguration getConfiguration() {
        return configuration;
    }

    @Override
    protected void performEnrichment(Inventory inventory) {
        LOG.info("Performing enrichment using [{}] yaml files", configuration.getYamlFiles().size());

        for (File file : configuration.getYamlFiles()) {
            ArtifactCorrelationUtil.addYamlToInventory(inventory, file);
        }
    }

    @Override
    protected String getEnrichmentName() {
        return "Artifact Correlation YAML";
    }

    @Override
    protected String getInventoryFileNameSuffix() {
        return "correlation";
    }
}
```

## Superclass `InventoryEnricherConfiguration`

Every enrichment step has its own configuration class. This class is used to pass additional parameters to the step.
There are a few good reasons that the configuration and system logic are separated:

- the configuration instance can be applied to multiple identical steps
- the configuration can easily be built using Maven magic in the `<configuration>` (see
  [example POM](../../../advisors/pom.xml) line ~150):
  ```xml
  <correlationYamlEnrichment>
      <active>${activate.correlation}</active>
      <yamlFiles>
          <file>${correlation.dir}</file>
      </yamlFiles>
  </correlationYamlEnrichment>
  ```
- separation of concerns: the configuration is only used to pass parameters, the actual logic is implemented in the
  `InventoryEnricher` class. This way, the actual implementation can be changed without changing the configuration
  parameters.

The only method that needs to be implemented is `getProperties()`. This method returns a `LinkedHashMap` that contains
all properties that make up the configuration. This is used to generate an entry in the `Info` sheet of the inventory,
where the pipeline puts all applied inventory enrichment steps and their configuration.

```java
public class ArtifactYamlEnrichmentConfiguration extends InventoryEnricherConfiguration {

    private final List<File> yamlFiles = new ArrayList<>();

    public ArtifactYamlEnrichmentConfiguration setYamlFiles(List<File> yamlFiles) {
        this.yamlFiles.clear();
        this.yamlFiles.addAll(yamlFiles);
        return this;
    }

    public ArtifactYamlEnrichmentConfiguration addYamlFile(File yamlFile) {
        this.yamlFiles.add(yamlFile);
        return this;
    }

    public List<File> getYamlFiles() {
        return yamlFiles;
    }

    @Override
    public LinkedHashMap<String, Object> getProperties() {
        final LinkedHashMap<String, Object> properties = new LinkedHashMap<>();

        properties.put("yamlFiles", yamlFiles);

        return properties;
    }
}
```
