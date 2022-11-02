@Deduplicate
Feature:Deduplicate - Verify Deduplicate Plugin Error scenarios

  @GCS_CSV_DEDUPLICATE_TEST
  Scenario:Verify Deduplicate plugin validation errors for invalid value of number of partitions
    Given Open Datafusion Project to configure pipeline
    When Select plugin: "GCS" from the plugins list as: "Source"
    When Expand Plugin group in the LHS plugins list: "Analytics"
    When Select plugin: "Deduplicate" from the plugins list as: "Analytics"
    Then Connect plugins: "GCS" and "Deduplicate" to establish connection
    Then Navigate to the properties page of plugin: "GCS"
    Then Replace input plugin property: "projectId" with value: "projectId"
    Then Enter input plugin property: "referenceName" with value: "GCSReferenceName"
    Then Enter input plugin property: "path" with value: "gcsSourcePath"
    Then Select dropdown plugin property: "format" with option value: "csv"
    Then Click plugin property: "skipHeader"
    Then Capture the generated Output Schema
    Then Click on the Get Schema button
    Then Validate "GCS" plugin properties
    Then Close the Plugin Properties page
    Then Navigate to the properties page of plugin: "Deduplicate"
    Then Select dropdown plugin property: "uniqueFields" with option value: "Fname"
    Then Press ESC key to close the unique fields dropdown
    Then Enter Deduplicate plugin property: filterOperation field name with value: "deduplicateFilterFieldName"
    Then Select Deduplicate plugin property: filterOperation field function with value: "deduplicateFunction"
    Then Enter input plugin property: "deduplicateNumberOfPartitions" with value: "deduplicateInvalidNumberOfPartitions"
    Then Click on the Validate button
    Then Verify that the Plugin Property: "numPartitions" is displaying an in-line error message: "errorMessageDeduplicateInvalidNumberOfPartitions"

  @GCS_CSV_DEDUPLICATE_TEST
  Scenario:Verify Deduplicate plugin error for FilterOperation field with invalid function
    Given Open Datafusion Project to configure pipeline
    When Select plugin: "GCS" from the plugins list as: "Source"
    When Expand Plugin group in the LHS plugins list: "Analytics"
    When Select plugin: "Deduplicate" from the plugins list as: "Analytics"
    Then Connect plugins: "GCS" and "Deduplicate" to establish connection
    Then Navigate to the properties page of plugin: "GCS"
    Then Replace input plugin property: "projectId" with value: "projectId"
    Then Enter input plugin property: "referenceName" with value: "GCSReferenceName"
    Then Enter input plugin property: "path" with value: "gcsSourcePath"
    Then Select dropdown plugin property: "format" with option value: "csv"
    Then Click plugin property: "skipHeader"
    Then Capture the generated Output Schema
    Then Click on the Get Schema button
    Then Validate "GCS" plugin properties
    Then Close the Plugin Properties page
    Then Navigate to the properties page of plugin: "Deduplicate"
    Then Select dropdown plugin property: "uniqueFields" with option value: "Fname"
    Then Press ESC key to close the unique fields dropdown
    Then Enter Deduplicate plugin property: filterOperation field name with value: "deduplicateFieldName"
    Then Select Deduplicate plugin property: filterOperation field function with value: "deduplicateFunction"
    Then Click on the Validate button
    Then Verify that the Plugin Property: "filterOperation" is displaying an in-line error message: "errorMessageDeduplicateInvalidFunction"
