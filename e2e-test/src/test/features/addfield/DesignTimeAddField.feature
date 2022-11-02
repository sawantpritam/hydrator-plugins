@Add_Field
Feature: AddField Plugin - Design time scenarios

  @ADD-FIELD-DSGN-01
  Scenario: To verify user should be able to validate mandatory fields
    Given Open Datafusion Project to configure pipeline
    And Expand Plugin group in the LHS plugins list: "Transform"
    And Select plugin: "Add Field" from the plugins list as: "Transform"
    And Navigate to the properties page of plugin: "AddField"
    And Enter input plugin property: "addFieldFieldName" with value: "afFieldName"
    And Enter input plugin property: "addFieldFieldValue" with value: "afFieldValue"
    ##And Select dropdown plugin property: "addFieldGenerateUUID" with option value: "true"
    And Validate "AddField" plugin properties

  @FILE_SOURCE_TEST @ADD-FIELD-DSGN-02
  Scenario: Verify output schema in add field plugin
    Given Open Datafusion Project to configure pipeline
    And Select plugin: "File" from the plugins list as: "Source"
    And Expand Plugin group in the LHS plugins list: "Transform"
    And Select plugin: "Add Field" from the plugins list as: "Transform"
    And Connect plugins: "File" and "AddField" to establish connection
    And Navigate to the properties page of plugin: "File"
    And Enter input plugin property: "referenceName" with value: "FileReferenceName"
    And Enter input plugin property: "path" with value: "csvAllDataTypeFile"
    And Select dropdown plugin property: "format" with option value: "csv"
    And Click plugin property: "skipHeader"
    And Click on the Get Schema button
    And Validate "File" plugin properties
    And Close the Plugin Properties page
    And Navigate to the properties page of plugin: "AddField"
    And Enter input plugin property: "addFieldFieldName" with value: "afFieldName"
    And Enter input plugin property: "addFieldFieldValue" with value: "afFieldValue"
    And Validate "AddField" plugin properties
    And Validate output schema with expectedSchema "csvAllDataTypeFileSchemaAddField"
