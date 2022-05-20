@LookUp
Feature:LookUp - Verification of LookUp pipeline with BigQuery and GCS as source to target BigQuery2 using macros

  @BQ_SOURCE_LOOKUP_TEST @GCS_CSV_LOOKUP_TEST @BQ_SINK_TEST
  Scenario: To verify complete flow of data extract and transfer from BigQuery and GCS as source to target BigQuery2  with LookUp plugin properties as macro arguments
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
    Then Click on the Get Schema button
    Then Capture the generated Output Schema
    Then Validate "BigQuery" plugin properties
    Then Close the Plugin Properties page
    Then Connect plugins: "BigQuery" and "Lookup" to establish connection
    Then Navigate to the properties page of plugin: "Lookup"
    Then Click on the Macro button of Property: "Lookupdataset" and set the value to: "lookupdataset"
    Then Click on the Macro button of Property: "Inputkeyfield" and set the value to: "lookUpInputKeyField"
    Then Click on the Macro button of Property: "Lookupkeyfield" and set the value to: "lookUpKeyField"
    Then Click on the Macro button of Property: "Lookupvaluefield" and set the value to: "lookUpValueField"
    Then Click on the Macro button of Property: "Outputfield" and set the value to: "lookUpOutputField"
    Then Validate "Lookup" plugin properties
    Then Close the Plugin Properties page
    When Expand Plugin group in the LHS plugins list: "Sink"
    When Select plugin: "BigQuery" from the plugins list as: "Sink"
    Then Connect plugins: "Lookup" and "BigQuery2" to establish connection
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
    Then Enter runtime argument value "Lookupdataset" for key "lookupdataset"
    Then Enter runtime argument value "Inputkeyfield" for key "lookUpInputKeyField"
    Then Enter runtime argument value "LookupKeyField" for key "lookUpKeyField"
    Then Enter runtime argument value "Lookupvaluefield" for key "lookUpValueField"
    Then Enter runtime argument value "Outputfield" for key "lookUpOutputField"
    Then Run the preview of pipeline with runtime arguments
    Then Wait till pipeline preview is in running state
    Then Open and capture pipeline preview logs
    Then Verify the preview run status of pipeline in the logs is "succeeded"
    Then Close the pipeline logs
    Then Click on the Preview Data link on the Sink plugin node: "BigQueryTable"
    Then Close the preview data
    Then Deploy the pipeline
    Then Run the Pipeline in Runtime
    Then Enter runtime argument value "Lookupdataset" for key "lookupdataset"
    Then Enter runtime argument value "Inputkeyfield" for key "lookUpInputKeyField"
    Then Enter runtime argument value "LookupKeyField" for key "lookUpKeyField"
    Then Enter runtime argument value "Lookupvaluefield" for key "lookUpValueField"
    Then Enter runtime argument value "Outputfield" for key "lookUpOutputField"
    Then Run the Pipeline in Runtime with runtime arguments
    Then Wait till pipeline is in running state
    Then Open and capture logs
    Then Verify the pipeline status is "Succeeded"
    Then Close the pipeline logs
