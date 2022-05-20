@LookUp
Feature: LookUp - Verification of LookUp Plugin pipeline with BigQuery and GCS as source and  BigQuery as target

  @BQ_SOURCE_LOOKUP_TEST @GCS_CSV_LOOKUP_TEST @BQ_SINK_TEST
  Scenario: To verify complete flow of data extract and transfer from BigQuery and GCS as source to target BigQuery2  with LookUp plugin using GCS lookup dataset.
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
    Then Enter input plugin property: "Inputkeyfield" with value: "lookUpInputKeyField"
    Then Enter input plugin property: "Lookupkeyfield" with value: "lookUpKeyField"
    Then Enter input plugin property: "Lookupvaluefield" with value: "lookUpValueField"
    Then Enter input plugin property: "Outputfield" with value: "lookUpOutputField"
    Then Select dropdown plugin property: "Lookupdataset" with option value: "GCS"
    Then Press ESC key to close the Lookup dataset dropdown
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
    Then Wait till pipeline preview is in running state
    Then Open and capture pipeline preview logs
    Then Verify the preview run status of pipeline in the logs is "succeeded"
    Then Close the pipeline logs
    Then Click on the Preview Data link on the Sink plugin node: "BigQueryTable"
    Then Close the preview data
    Then Deploy the pipeline
    Then Run the Pipeline in Runtime
    Then Wait till pipeline is in running state
    Then Open and capture logs
    Then Verify the pipeline status is "Succeeded"
    Then Close the pipeline logs
    Then Verify columnList: "lookupExpectedTargetTableColumnListGCS" of target BigQuery table: "bqTargetTable"

  @BQ_SOURCE_LOOKUP_TEST @GCS_CSV_LOOKUP_TEST @BQ_SINK_TEST
  Scenario:To verify complete flow of data extract and transfer from sources GCS and BigQuery to target BigQuery2 with LookUp plugin using BigQuery lookup dataset.
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
    Then Validate "BigQuery2" plugin properties
    Then Close the Plugin Properties page
    Then Connect plugins: "BigQuery" and "Lookup" to establish connection
    Then Navigate to the properties page of plugin: "Lookup"
    Then Enter input plugin property: "Inputkeyfield" with value: "lookUpInputKeyField"
    Then Enter input plugin property: "Lookupkeyfield" with value: "lookUpKeyField"
    Then Enter input plugin property: "Lookupvaluefield" with value: "lookUpValueField1"
    Then Enter input plugin property: "Outputfield" with value: "lookUpOutputField1"
    Then Select dropdown plugin property: "Lookupdataset" with option value: "BigQuery"
    Then Press ESC key to close the Lookup dataset dropdown
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
    Then Wait till pipeline preview is in running state
    Then Open and capture pipeline preview logs
    Then Verify the preview run status of pipeline in the logs is "succeeded"
    Then Close the pipeline logs
    Then Click on the Preview Data link on the Sink plugin node: "BigQueryTable"
    Then Close the preview data
    Then Deploy the pipeline
    Then Run the Pipeline in Runtime
    Then Wait till pipeline is in running state
    Then Open and capture logs
    Then Verify the pipeline status is "Succeeded"
    Then Close the pipeline logs
    Then Verify columnList: "lookupExpectedTargetTableColumnListBigQuery" of target BigQuery table: "bqTargetTable"

  @BQ_SOURCE_LOOKUP_TEST @GCS_CSV_LOOKUP_TEST @BQ_SINK_TEST
  Scenario: To verify complete flow of data extract and transfer from sources GCS and BigQuery to target BigQuery2 with LookUp plugin without using Output field.
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
    Then Validate "BigQuery2" plugin properties
    Then Close the Plugin Properties page
    Then Connect plugins: "BigQuery" and "Lookup" to establish connection
    Then Navigate to the properties page of plugin: "Lookup"
    Then Enter input plugin property: "Inputkeyfield" with value: "lookUpInputKeyField"
    Then Enter input plugin property: "Lookupkeyfield" with value: "lookUpKeyField"
    Then Enter input plugin property: "Lookupvaluefield" with value: "lookUpValueField"
    Then Select dropdown plugin property: "Lookupdataset" with option value: "GCS"
    Then Press ESC key to close the Lookup dataset dropdown
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
    Then Wait till pipeline preview is in running state
    Then Open and capture pipeline preview logs
    Then Verify the preview run status of pipeline in the logs is "succeeded"
    Then Close the pipeline logs
    Then Click on the Preview Data link on the Sink plugin node: "BigQueryTable"
    Then Close the preview data
    Then Deploy the pipeline
    Then Run the Pipeline in Runtime
    Then Wait till pipeline is in running state
    Then Open and capture logs
    Then Verify the pipeline status is "Succeeded"
    Then Close the pipeline logs
    Then Verify columnList: "lookupExpectedTargetTableColumnListWithoutOutputField" of target BigQuery table: "bqTargetTable"
