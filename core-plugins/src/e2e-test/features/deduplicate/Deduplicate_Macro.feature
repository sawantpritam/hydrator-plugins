@Deduplicate
Feature:Deduplicate- Verification of Deduplicate pipeline with File as source and File as target using macros

  @FILE_SOURCE_TEST @FILE_SINK_TEST
  Scenario: To verify data is getting transferred from File to File successfully with Deduplicate plugin properties as macro arguments
    Given Open Datafusion Project to configure pipeline
    When Select plugin: "File" from the plugins list as: "Source"
    When Expand Plugin group in the LHS plugins list: "Analytics"
    When Select plugin: "Deduplicate" from the plugins list as: "Analytics"
    Then Connect plugins: "File" and "Deduplicate" to establish connection
    Then Navigate to the properties page of plugin: "File"
    Then Enter input plugin property: "referenceName" with value: "FileReferenceName"
    Then Enter input plugin property: "path" with value: "deduplicateFileCsvFile"
    Then Select dropdown plugin property: "format" with option value: "csv"
    Then Click plugin property: "skipHeader"
    Then Click on the Get Schema button
    Then Verify the Output Schema matches the Expected Schema: "deduplicateOutputSchema"
    Then Validate "File" plugin properties
    Then Close the Plugin Properties page
    Then Navigate to the properties page of plugin: "Deduplicate"
    Then Click on the Macro button of Property: "deduplicateUniqueFields" and set the value to: "deduplicateUniqueFields"
    Then Click on the Macro button of Property: "filterOperation" and set the value to: "deduplicateFilterOperation"
    Then Click on the Macro button of Property: "deduplicateNumPartitions" and set the value to: "deduplicateNumberOfPartitions"
    Then Validate "Deduplicate" plugin properties
    Then Close the Plugin Properties page
    When Expand Plugin group in the LHS plugins list: "Sink"
    When Select plugin: "File" from the plugins list as: "Sink"
    Then Connect plugins: "Deduplicate" and "File2" to establish connection
    Then Navigate to the properties page of plugin: "File2"
    Then Enter input plugin property: "referenceName" with value: "FileReferenceName"
    Then Enter input plugin property: "path" with value: "filePluginOutputFolder"
    Then Replace input plugin property: "pathSuffix" with value: "yyyy-MM-dd-HH-mm-ss"
    Then Select dropdown plugin property: "format" with option value: "csv"
    Then Validate "File" plugin properties
    Then Close the Plugin Properties page
    Then Save the pipeline
    Then Preview and run the pipeline
    Then Enter runtime argument value "deduplicateUniqueFields" for key "deduplicateUniqueFields"
    Then Enter runtime argument value "deduplicateFilterOperation" for key "deduplicateFilterOperation"
    Then Enter runtime argument value "deduplicateNumberOfPartitions" for key "deduplicateNumberOfPartitions"
    Then Run the preview of pipeline with runtime arguments
    Then Wait till pipeline preview is in running state
    Then Open and capture pipeline preview logs
    Then Verify the preview run status of pipeline in the logs is "succeeded"
    Then Close the pipeline logs
    Then Close the preview
    Then Deploy the pipeline
    Then Run the Pipeline in Runtime
    Then Enter runtime argument value "deduplicateUniqueFields" for key "deduplicateUniqueFields"
    Then Enter runtime argument value "deduplicateFilterOperation" for key "deduplicateFilterOperation"
    Then Enter runtime argument value "deduplicateNumberOfPartitions" for key "deduplicateNumberOfPartitions"
    Then Run the Pipeline in Runtime with runtime arguments
    Then Wait till pipeline is in running state
    Then Open and capture logs
    Then Verify the pipeline status is "Succeeded"
    Then Close the pipeline logs
    Then Validate OUT record count of deduplicate is equal to IN record count of sink
    Then Validate output records in output folder path "filePluginOutputFolder" is equal to expected output file "deduplicateMacroOutputFile"
