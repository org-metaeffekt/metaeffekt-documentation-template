> [Vulnerability Monitoring](../inventory-enrichment-overview.md) > [Inventory Enrichment](inventory-enrichment.md) >
> Maven POM

# Maven POM

A full example with all configuration parameters can be found in
[advisors/pom.xml line ~145](../../../advisors/pom.xml).

To use it, activate the `com.metaeffekt.artifact.analysis` : `ae-inventory-enrichment-plugin` : `enrich-inventory` goal
in the plugin section of a build tag. Inside the configuration, the enrichment steps can be defined.

The order in which these enrichers appear in does not matter to the enrichment pipeline, as the order specified
in `enrichmentOrder` will be used. This defaults to the [default order](steps.md). A custom order can be specified by
using the names from the configuration parameters (i.e. `correlationYamlEnrichment`).

The configuration instances are built using maven's instance creation system. The properties of a
[configuration](java-super-classes.md#superclass-inventoryenricherconfiguration) can be overwritten by specifying them
inside a tag with the same name. Replace lists entries with child tag entries.

```xml
<plugins>
    <plugin>
        <groupId>com.metaeffekt.artifact.analysis</groupId>
        <artifactId>ae-inventory-enrichment-plugin</artifactId>
        <version>${ae.artifact.analysis.version}</version>

        <executions>
            <execution>
                <id>inventory-enrichment-execution</id>
                <goals>
                    <goal>enrich-inventory</goal>
                </goals>

                <configuration>
                    <inventoryInputFile>${input.inventory}</inventoryInputFile>
                    <inventoryOutputFile>${output.inventory}</inventoryOutputFile>
                    <mirrorDirectory>${input.database}</mirrorDirectory>

                    <writeIntermediateInventories>true</writeIntermediateInventories>
                    <storeIntermediateStepsInInventoryInfo>true</storeIntermediateStepsInInventoryInfo>
                    <intermediateInventoriesDirectory>${output.inventory.intermediate.dir}</intermediateInventoriesDirectory>

                    <!--<resumeAtEnrichment>resume-at</resumeAtEnrichment>-->
                    <!--<enrichmentOrder></enrichmentOrder>-->

                    <correlationYamlEnrichment>
                        <active>${activate.correlation}</active>
                        <yamlFiles>
                            <file>${correlation.dir}</file>
                        </yamlFiles>
                    </correlationYamlEnrichment>

                    <cpeDerivationEnrichment>
                        <active>${activate.nvd}</active>
                        <maxCorrelatedCpePerArtifact>2147483647</maxCorrelatedCpePerArtifact>
                    </cpeDerivationEnrichment>

                    <msVulnerabilitiesByProductEnrichment>
                        <active>${activate.msrc}</active>
                    </msVulnerabilitiesByProductEnrichment>

                    <nvdMatchCveFromCpeEnrichment>
                        <active>${activate.nvd}</active>
                        <maxCorrelatedVulnerabilitiesPerArtifact>2147483647</maxCorrelatedVulnerabilitiesPerArtifact>
                    </nvdMatchCveFromCpeEnrichment>

                    <customVulnerabilitiesFromCpeEnrichment>
                        <active>${activate.vulnerabilities.custom}</active>
                        <vulnerabilityFiles>
                            <file>${vulnerabilities.custom.dir}</file>
                        </vulnerabilityFiles>
                    </customVulnerabilitiesFromCpeEnrichment>


                    <nvdCveFillDetailsEnrichment>
                        <active>${activate.nvd}</active>
                        <cvssSeverityRanges>${cvssSeverityRanges}</cvssSeverityRanges>
                    </nvdCveFillDetailsEnrichment>

                    <customVulnerabilitiesFillDetailsEnrichment>
                        <active>${activate.vulnerabilities.custom}</active>
                        <vulnerabilityFiles>
                            <file>${vulnerabilities.custom.dir}</file>
                        </vulnerabilityFiles>
                        <cvssSeverityRanges>${cvssSeverityRanges}</cvssSeverityRanges>
                    </customVulnerabilitiesFillDetailsEnrichment>

                    <msrcAdvisorFillDetailsEnrichment>
                        <active>${activate.msrc}</active>
                        <cvssSeverityRanges>${cvssSeverityRanges}</cvssSeverityRanges>
                    </msrcAdvisorFillDetailsEnrichment>


                    <vulnerabilityStatusEnrichment>
                        <active>${activate.status}</active>
                        <statusFiles>
                            <file>${assessment.dir}</file>
                        </statusFiles>
                        <cvssSeverityRanges>${cvssSeverityRanges}</cvssSeverityRanges>
                        <activeLabels>${assessment.labels}</activeLabels>
                    </vulnerabilityStatusEnrichment>

                    <vulnerabilityKeywordsEnrichment>
                        <active>${activate.keywords}</active>
                        <yamlFiles>
                            <file>${keywords.dir}</file>
                        </yamlFiles>
                        <cvssSeverityRanges>${cvssSeverityRanges}</cvssSeverityRanges>
                        <activeLabels>${keywords.dir}</activeLabels>
                    </vulnerabilityKeywordsEnrichment>


                    <certFrAdvisorEnrichment>
                        <active>${activate.certfr}</active>
                        <cvssSeverityRanges>${cvssSeverityRanges}</cvssSeverityRanges>
                    </certFrAdvisorEnrichment>

                    <certSeiAdvisorEnrichment>
                        <active>${activate.certsei}</active>
                        <cvssSeverityRanges>${cvssSeverityRanges}</cvssSeverityRanges>
                    </certSeiAdvisorEnrichment>


                    <vulnerabilityFilterEnrichment>
                        <active>false</active>
                        <vulnerabilityIncludeFilter></vulnerabilityIncludeFilter>
                    </vulnerabilityFilterEnrichment>

                    <vulnerabilityAssessmentDashboardEnrichment>
                        <active>${activate.dashboard}</active>
                        <outputDashboardFile>${output.dashboard}</outputDashboardFile>
                        <svgDirectory>${output.svg}</svgDirectory>

                        <!-- deprecated: Use vulnerabilityIncludeFilter instead -->
                        <minimumVulnerabilityIncludeScore>-2147483648</minimumVulnerabilityIncludeScore>
                        <vulnerabilityIncludeFilter></vulnerabilityIncludeFilter>
                        <maximumVulnerabilitiesPerDashboardCount>2147483647</maximumVulnerabilitiesPerDashboardCount>
                        <insignificantThreshold>${ae.dashboard.insignificant.threshold}</insignificantThreshold>

                        <vulnerabilityTimelinesGlobalEnabled>${ae.dashboard.timeline}</vulnerabilityTimelinesGlobalEnabled>
                        <maximumCpeForTimelinesPerVulnerability>2147483647</maximumCpeForTimelinesPerVulnerability>
                        <maximumVulnerabilitiesPerTimeline>${ae.dashboard.cpe.limit}</maximumVulnerabilitiesPerTimeline>
                        <vulnerabilityTimelineHideIrrelevantVersions>true</vulnerabilityTimelineHideIrrelevantVersions>
                        <maximumVersionsPerTimeline>2147483647</maximumVersionsPerTimeline>
                        <maximumTimeSpentOnTimelines>2147483647</maximumTimeSpentOnTimelines>

                        <failOnVulnerabilityWithoutSpecifiedRisk>true</failOnVulnerabilityWithoutSpecifiedRisk>
                        <failOnUnreviewedAdvisories>true</failOnUnreviewedAdvisories>
                        <failOnUnreviewedAdvisoriesTypes></failOnUnreviewedAdvisoriesTypes>
                        <cvssSeverityRanges>${cvssSeverityRanges}</cvssSeverityRanges>
                    </vulnerabilityAssessmentDashboardEnrichment>
                </configuration>
            </execution>
        </executions>
    </plugin>
</plugins>
```
