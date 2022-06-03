@LookUp
Feature:LookUp - Verify LookUp Plugin Error scenarios

  Scenario:Verify LookUp plugin validation errors for mandatory fields
    Given Open Datafusion Project to configure pipeline
    When Expand Plugin group in the LHS plugins list: "Analytics"
    When Select plugin: "Lookup" from the plugins list as: "Analytics"
    Then Navigate to the properties page of plugin: "Lookup"
    Then Click on the Validate button
    Then Verify mandatory property error for below listed properties:
      | lookupDataset    |
      | inputKeyField    |
      | lookupKeyField   |
      | lookupValueField |

  @BQ_SOURCE_LOOKUP_TEST @GCS_CSV_LOOKUP_TEST @BQ_SINK_TEST
  Scenario:Verify LookUp plugin error for Lookup value field not in dataset
    Given Open Datafusion Project to configure pipeline
    When Select plugin: "GCS" from the plugins list as: "Source"
    When Expand Plugin group in the LHS plugins list: "Analytics"
    When Select plugin: "Lookup" from the plugins list as: "Analytics"
    Then Connect plugins: "GCS" and "Lookup" to establish connection
    Then Navigate to the properties page of plugin: "GCS"
    Then Replace input plugin property: "projectId" with value: "projectId"
    Then Enter input plugin property: "referenceName" with value: "GCSReferenceName"
    Then Enter input plugin property: "path" with value: "gcsSourcePath"
    Then Select dropdown plugin property: "format" with option value: "csv"
    Then Click plugin property: "skipHeader"
    Then Click on the Get Schema button
    Then Validate "GCS" plugin properties
    Then Close the Plugin Properties page
    When Expand Plugin group in the LHS plugins list: "Source"
    When Select plugin: "BigQuery" from the plugins list as: "Source"
    Then Navigate to the properties page of plugin: "BigQuery"
    Then Replace input plugin property: "projectId" with value: "projectId"
    Then Enter input plugin property: "datasetProjectId" with value: "projectId"
    Then Enter input plugin property: "referenceName" with value: "BQReferenceName"
    Then Enter input plugin property: "dataset" with value: "dataset"
    Then Enter input plugin property: "table" with value: "bqSourceTable"
    Then Validate "BigQuery" plugin properties
    Then Close the Plugin Properties page
    Then Connect plugins: "BigQuery" and "Lookup" to establish connection
    Then Navigate to the properties page of plugin: "Lookup"
    Then Select dropdown plugin property: "lookUpDataSet" with option value: "BigQuery"
    Then Press ESC key to close the Lookup dataset dropdown
    Then Enter input plugin property: "lookUpInputKeyField" with value: "lookUpInputKeyField"
    Then Enter input plugin property: "lookUpKeyField" with value: "lookUpKeyField"
    Then Enter input plugin property: "lookUpValueField" with value: "lookUpValueField"
    Then Enter input plugin property: "lookUpOutputField" with value: "lookUpOutputField"
    Then Click on the Validate button
    Then Verify that the Plugin is displaying an error message: "errorMessageLookUpValueFieldNotFound" on the header

  @BQ_SOURCE_LOOKUP_TEST @GCS_CSV_LOOKUP_TEST @BQ_SINK_TEST
  Scenario:Verify LookUp plugin error when select all Lookup datasets
    Given Open Datafusion Project to configure pipeline
    When Select plugin: "GCS" from the plugins list as: "Source"
    When Expand Plugin group in the LHS plugins list: "Analytics"
    When Select plugin: "Lookup" from the plugins list as: "Analytics"
    Then Connect plugins: "GCS" and "Lookup" to establish connection
    Then Navigate to the properties page of plugin: "GCS"
    Then Replace input plugin property: "projectId" with value: "projectId"
    Then Enter input plugin property: "referenceName" with value: "GCSReferenceName"
    Then Enter input plugin property: "path" with value: "gcsSourcePath"
    Then Select dropdown plugin property: "format" with option value: "csv"
    Then Click plugin property: "skipHeader"
    Then Validate "GCS" plugin properties
    Then Close the Plugin Properties page
    When Expand Plugin group in the LHS plugins list: "Source"
    When Select plugin: "BigQuery" from the plugins list as: "Source"
    Then Navigate to the properties page of plugin: "BigQuery"
    Then Replace input plugin property: "projectId" with value: "projectId"
    Then Enter input plugin property: "datasetProjectId" with value: "projectId"
    Then Enter input plugin property: "referenceName" with value: "BQReferenceName"
    Then Enter input plugin property: "dataset" with value: "dataset"
    Then Enter input plugin property: "table" with value: "bqSourceTable"
    Then Click on the Get Schema button
    Then Validate "BigQuery" plugin properties
    Then Close the Plugin Properties page
    Then Connect plugins: "BigQuery" and "Lookup" to establish connection
    Then Navigate to the properties page of plugin: "Lookup"
    Then Select dropdown plugin property: "lookUpDataSet" with option value: "BigQuery"
    Then Press ESC key to close the Lookup dataset dropdown
    Then Select dropdown plugin property: "lookUpDataSet" with option value: "GCS"
    Then Press ESC key to close the Lookup dataset dropdown
    Then Enter input plugin property: "lookUpInputKeyField" with value: "lookUpInputKeyField"
    Then Enter input plugin property: "lookUpKeyField" with value: "lookUpKeyField"
    Then Enter input plugin property: "lookUpValueField" with value: "lookUpValueField"
    Then Enter input plugin property: "lookUpOutputField" with value: "lookUpOutputField"
    Then Click on the Validate button
    Then Verify that the Plugin is displaying an error message: "errorMessageLookUpDatasetMissing" on the header
