@Deduplicate
Feature: Deduplicate - Verification of Deduplicate pipeline with BigQuery as source and target

  @BQ_SINK_TEST @BQ_SOURCE_DEDUPLICATE_TEST
  Scenario: To verify complete flow of data extract and transfer from BQ source to BQ sink using Deduplicate Plugin
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
    Then Enter Deduplicate plugin property: filterOperation field name with value: "fieldName"
    Then Select File plugin property: filterOperation field function with value: "function"
    Then Select dropdown plugin property: "uniqueFields" with option value: "fname"
    Then Press ESC key to close the unique fields dropdown
    Then Select dropdown plugin property: "uniqueFields" with option value: "lname"
    Then Press ESC key to close the unique fields dropdown
    Then Validate "Deduplicate" plugin properties
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
    Then Wait till pipeline preview is in running state
    Then Open and capture pipeline preview logs
    Then Verify the preview run status of pipeline in the logs is "succeeded"
    Then Close the pipeline logs
    Then Close the preview
    Then Deploy the pipeline
    Then Run the Pipeline in Runtime
    Then Wait till pipeline is in running state
    Then Open and capture logs
    Then Verify the pipeline status is "Succeeded"
    Then Close the pipeline logs
    Then Validate OUT record count is equal to IN record count

  @BQ_SINK_TEST @BQ_SOURCE_DEDUPLICATE_TEST
  Scenario: To verify complete flow of data extract and transfer from BQ source to BQ sink using Deduplicate Plugin with Number of Partitions
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
    Then Enter Deduplicate plugin property: filterOperation field name with value: "fieldName"
    Then Select File plugin property: filterOperation field function with value: "function"
    Then Select dropdown plugin property: "uniqueFields" with option value: "fname"
    Then Press ESC key to close the unique fields dropdown
    Then Select dropdown plugin property: "uniqueFields" with option value: "lname"
    Then Press ESC key to close the unique fields dropdown
    Then Enter input plugin property: "numberOfPartitions" with value: "deduplicateNumberOfPartitions"
    Then Validate "Deduplicate" plugin properties
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
    Then Wait till pipeline preview is in running state
    Then Open and capture pipeline preview logs
    Then Verify the preview run status of pipeline in the logs is "succeeded"
    Then Close the pipeline logs
    Then Close the preview
    Then Deploy the pipeline
    Then Run the Pipeline in Runtime
    Then Wait till pipeline is in running state
    Then Open and capture logs
    Then Verify the pipeline status is "Succeeded"
    Then Close the pipeline logs
    Then Validate OUT record count is equal to IN record count
