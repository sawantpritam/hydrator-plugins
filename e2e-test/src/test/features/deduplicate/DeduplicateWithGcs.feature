@Deduplicate
Feature: Deduplicate- Verification of Deduplicate Plugin pipeline with GCS as source and File as target

  @GCS_CSV_DEDUPLICATE_TEST @File_Sink @FILE_SINK_TEST
  Scenario: To verify complete flow of data extract and transfer from GCS as source to target File with Deduplicate plugin
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
    Then Enter Deduplicate plugin property: filterOperation field name with value: "deduplicateFilterFieldName"
    Then Select Deduplicate plugin property: filterOperation field function with value: "deduplicateFunction"
    Then Select dropdown plugin property: "uniqueFields" with option value: "Fname"
    Then Press ESC key to close the unique fields dropdown
    Then Select dropdown plugin property: "uniqueFields" with option value: "Lname"
    Then Press ESC key to close the unique fields dropdown
    Then Capture the generated Output Schema
    Then Validate "Deduplicate" plugin properties
    Then Close the Plugin Properties page
    When Expand Plugin group in the LHS plugins list: "Sink"
    When Select plugin: "File" from the plugins list as: "Sink"
    Then Connect plugins: "Deduplicate" and "File" to establish connection
    Then Navigate to the properties page of plugin: "File"
    Then Enter input plugin property: "referenceName" with value: "FileReferenceName"
    Then Enter input plugin property: "path" with value: "filePluginOutputFolder"
    Then Replace input plugin property: "pathSuffix" with value: "yyyy-MM-dd-HH-mm-ss"
    Then Select dropdown plugin property: "format" with option value: "csv"
    Then Validate "File" plugin properties
    Then Close the Plugin Properties page
    Then Save the pipeline
    Then Preview and run the pipeline
    Then Wait till pipeline preview is in running state
    Then Open and capture pipeline preview logs
    Then Verify the preview run status of pipeline in the logs is "succeeded"
    Then Close the pipeline logs
    Then Click on the Preview Data link on the Sink plugin node: "File"
    Then Close the preview data
    Then Deploy the pipeline
    Then Run the Pipeline in Runtime
    Then Wait till pipeline is in running state
    Then Open and capture logs
    Then Verify the pipeline status is "Succeeded"
    Then Close the pipeline logs

  @GCS_CSV_DEDUPLICATE_TEST @File_Sink @FILE_SINK_TEST
  Scenario: To verify complete flow of data extract and transfer from GCS as source to target File using Deduplicate plugin with Number of Partitions
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
    Then Enter Deduplicate plugin property: filterOperation field name with value: "deduplicateFilterFieldName"
    Then Select Deduplicate plugin property: filterOperation field function with value: "deduplicateFunction"
    Then Select dropdown plugin property: "uniqueFields" with option value: "Fname"
    Then Press ESC key to close the unique fields dropdown
    Then Select dropdown plugin property: "uniqueFields" with option value: "Lname"
    Then Press ESC key to close the unique fields dropdown
    Then Enter input plugin property: "deduplicateNumberOfPartitions" with value: "deduplicateNumberOfPartitions"
    Then Capture the generated Output Schema
    Then Validate "Deduplicate" plugin properties
    Then Close the Plugin Properties page
    When Expand Plugin group in the LHS plugins list: "Sink"
    When Select plugin: "File" from the plugins list as: "Sink"
    Then Connect plugins: "Deduplicate" and "File" to establish connection
    Then Navigate to the properties page of plugin: "File"
    Then Enter input plugin property: "referenceName" with value: "FileReferenceName"
    Then Enter input plugin property: "path" with value: "filePluginOutputFolder"
    Then Replace input plugin property: "pathSuffix" with value: "yyyy-MM-dd-HH-mm-ss"
    Then Select dropdown plugin property: "format" with option value: "csv"
    Then Validate "File" plugin properties
    Then Close the Plugin Properties page
    Then Save the pipeline
    Then Preview and run the pipeline
    Then Wait till pipeline preview is in running state
    Then Open and capture pipeline preview logs
    Then Verify the preview run status of pipeline in the logs is "succeeded"
    Then Close the pipeline logs
    Then Click on the Preview Data link on the Sink plugin node: "File"
    Then Close the preview data
    Then Deploy the pipeline
    Then Run the Pipeline in Runtime
    Then Wait till pipeline is in running state
    Then Open and capture logs
    Then Verify the pipeline status is "Succeeded"
    Then Close the pipeline logs
