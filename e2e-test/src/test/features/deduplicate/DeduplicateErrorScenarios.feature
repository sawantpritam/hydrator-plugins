@Deduplicate
Feature:Deduplicate - Verify DateTransform Plugin Error scenarios

  @BQ_SOURCE_DEDUPLICATE_TEST
  Scenario:Verify Deduplicate plugin validation errors for invalid value of number of partitions
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
    Then Select dropdown plugin property: "uniqueFields" with option value: "fname"
    Then Press ESC key to close the unique fields dropdown
    Then Enter Deduplicate plugin property: filterOperation field name with value: "fieldName"
    Then Select File plugin property: filterOperation field function with value: "function"
    Then Enter input plugin property: "numberOfPartitions" with value: "deduplicateInvalidNumberOfPartitions"
    Then Click on the Validate button
    Then Verify that the Plugin Property: "numPartitions" is displaying an in-line error message: "errorMessageDeduplicateInvalidNumberOfPartitions"

  @BQ_SOURCE_DEDUPLICATE_TEST
  Scenario:Verify Deduplicate plugin error for FilterOperation field with invalid function
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
    Then Select dropdown plugin property: "uniqueFields" with option value: "fname"
    Then Press ESC key to close the unique fields dropdown
    Then Enter Deduplicate plugin property: filterOperation field name with value: "FieldName"
    Then Select File plugin property: filterOperation field function with value: "function"
    Then Click on the Validate button
    Then Verify that the Plugin Property: "filterOperation" is displaying an in-line error message: "errorMessageDuplicateInvalidFunction"
