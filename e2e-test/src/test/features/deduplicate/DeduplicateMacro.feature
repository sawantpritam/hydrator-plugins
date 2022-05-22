@Deduplicate
Feature:Deduplicate- Verification of Deduplicate pipeline with BigQuery as source and target using macros

  @BQ_SINK_TEST @BQ_SOURCE_DEDUPLICATE_TEST
  Scenario: To verify data is getting transferred from BigQuery to BigQuery successfully with DateTransform plugin properties as macro arguments
    Given Open Datafusion Project to configure pipeline
    When Select plugin: "BigQuery" from the plugins list as: "Source"
    When Expand Plugin group in the LHS plugins list: "Analytics"
    When Select plugin: "Deduplicate" from the plugins list as: "Analytics"
    Then Connect plugins: "BigQuery" and "Deduplicate" to establish connection
    Then Navigate to the properties page of plugin: "BigQuery"
    Then Replace input plugin property: "projectId" with value: "projectId"
    Then Enter input plugin property: "datasetProjectId" with value: "projectId"
    Then Enter input plugin property: "referenceName" with value: "BQReferenceName"
    Then Enter input plugin property: "dataset" with value: "dataset"
    Then Enter input plugin property: "table" with value: "bqSourceTable"
    Then Click on the Get Schema button
    Then Capture the generated Output Schema
    Then Validate "BigQuery" plugin properties
    Then Close the Plugin Properties page
    Then Navigate to the properties page of plugin: "Deduplicate"
    Then Click on the Macro button of Property: "uniqueFields" and set the value to: "deduplicateUniqueFields"
    Then Click on the Macro button of Property: "filterOperation" and set the value to: "deduplicateFilterOperation"
    Then Click on the Macro button of Property: "numberOfPartitions" and set the value to: "deduplicateNumberOfPartitions"
    Then Validate "Date Transform" plugin properties
    Then Close the Plugin Properties page
    When Expand Plugin group in the LHS plugins list: "Sink"
    When Select plugin: "BigQuery" from the plugins list as: "Sink"
    Then Connect plugins: "Deduplicate" and "BigQuery2" to establish connection
    Then Navigate to the properties page of plugin: "BigQuery2"
    Then Replace input plugin property: "projectId" with value: "projectId"
    Then Enter input plugin property: "datasetProjectId" with value: "projectId"
    Then Enter input plugin property: "referenceName" with value: "BQReferenceName"
    Then Enter input plugin property: "dataset" with value: "dataset"
    Then Enter input plugin property: "table" with value: "bqTargetTable"
    Then Validate "BigQuery2" plugin properties
    Then Close the Plugin Properties page
    Then Save the pipeline
    Then Preview and run the pipeline
    Then Enter runtime argument value "uniqueFields" for key "deduplicateUniqueFields"
    Then Enter runtime argument value "filterOperation" for key "deduplicateFilterOperation"
    Then Enter runtime argument value "numberOfPartitions" for key "deduplicateNumberOfPartitions"
    Then Run the preview of pipeline with runtime arguments
    Then Wait till pipeline preview is in running state
    Then Open and capture pipeline preview logs
    Then Verify the preview run status of pipeline in the logs is "succeeded"
    Then Close the pipeline logs
    Then Click on the Preview Data link on the Sink plugin node: "BigQueryTable"
    Then Close the preview data
    Then Deploy the pipeline
    Then Run the Pipeline in Runtime
    Then Enter runtime argument value "uniqueFields" for key "deduplicateUniqueFields"
    Then Enter runtime argument value "filterOperation" for key "deduplicateFilterOperation"
    Then Enter runtime argument value "numberOfPartitions" for key "deduplicateNumberOfPartitions"
    Then Run the Pipeline in Runtime with runtime arguments
    Then Wait till pipeline is in running state
    Then Open and capture logs
    Then Verify the pipeline status is "Succeeded"
    Then Close the pipeline logs
    Then Validate OUT record count is equal to IN record count
