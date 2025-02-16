/*
 * Copyright © 2018-2022 Cask Data, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package io.cdap.plugin.format.delimited.input;

import com.google.common.annotations.VisibleForTesting;
import io.cdap.cdap.api.annotation.Description;
import io.cdap.cdap.api.annotation.Macro;
import io.cdap.cdap.api.annotation.Name;
import io.cdap.cdap.api.annotation.Plugin;
import io.cdap.cdap.api.data.schema.Schema;
import io.cdap.cdap.api.plugin.PluginClass;
import io.cdap.cdap.api.plugin.PluginPropertyField;
import io.cdap.cdap.etl.api.FailureCollector;
import io.cdap.cdap.etl.api.validation.FormatContext;
import io.cdap.cdap.etl.api.validation.InputFile;
import io.cdap.cdap.etl.api.validation.InputFiles;
import io.cdap.cdap.etl.api.validation.ValidatingInputFormat;
import io.cdap.plugin.format.delimited.common.DataTypeDetectorStatusKeeper;
import io.cdap.plugin.format.delimited.common.DataTypeDetectorUtils;
import io.cdap.plugin.format.input.PathTrackingConfig;
import io.cdap.plugin.format.input.PathTrackingInputFormatProvider;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.annotation.Nullable;

/**
 * Reads delimited text into StructuredRecords.
 */
@Plugin(type = ValidatingInputFormat.PLUGIN_TYPE)
@Name(DelimitedInputFormatProvider.NAME)
@Description(DelimitedInputFormatProvider.DESC)
public class DelimitedInputFormatProvider extends PathTrackingInputFormatProvider<DelimitedInputFormatProvider.Conf> {
  public static final PluginClass PLUGIN_CLASS = getPluginClass();
  static final String NAME = "delimited";
  static final String DESC = "Plugin for reading files in delimited format.";
  private final Conf conf;

  public DelimitedInputFormatProvider(Conf conf) {
    super(conf);
    this.conf = conf;
  }

  @Override
  public String getInputFormatClassName() {
    return CombineDelimitedInputFormat.class.getName();
  }

  @Override
  protected void validate() {
    if (!conf.containsMacro(PathTrackingConfig.NAME_SCHEMA) && conf.getSchema() == null) {
      throw new IllegalArgumentException("Delimited format cannot be used without specifying a schema.");
    }
  }

  @Override
  public void validate(FormatContext context) {
    Schema schema = super.getSchema(context);
    FailureCollector collector = context.getFailureCollector();
    if (!conf.containsMacro(PathTrackingConfig.NAME_SCHEMA) && schema == null && context.getInputSchema() == null) {
      collector.addFailure(
        "Delimited format cannot be used without specifying a schema.",
        "Schema must be specified.")
        .withConfigProperty("schema");
    }

    if (conf.containsMacro(DelimitedConfig.NAME_ENABLE_QUOTES_VALUES) || conf.containsMacro(Conf.DELIMITER)) {
      return;
    }

    if (conf.getEnableQuotedValues() && conf.delimiter != null && conf.delimiter.contains("\"")) {
      collector.addFailure(
        "The delimiter %s cannot contain \" when quoted values are enabled.",
        "Check the delimiter.")
        .withConfigProperty("delimiter");
    }
  }

  @Override
  protected void addFormatProperties(Map<String, String> properties) {
    properties.put(PathTrackingDelimitedInputFormat.DELIMITER, conf.delimiter == null ? "," : conf.delimiter);
    properties.put(PathTrackingDelimitedInputFormat.SKIP_HEADER, String.valueOf(conf.getSkipHeader()));
    properties.put(PathTrackingDelimitedInputFormat.ENABLE_QUOTES_VALUE, String.valueOf(conf.getEnableQuotedValues()));
  }

  @Nullable
  @Override
  public Schema detectSchema(FormatContext context, InputFiles inputFiles) throws IOException {
    return detectSchema(conf, conf.delimiter == null ? "," : conf.delimiter, inputFiles, context);
  }

  static Schema detectSchema(DelimitedConfig conf, String delimiter,
                             InputFiles inputFiles, FormatContext context) throws IOException {
    DataTypeDetectorStatusKeeper dataTypeDetectorStatusKeeper = new DataTypeDetectorStatusKeeper();
    for (InputFile inputFile : inputFiles) {
      String line;
      String[] columnNames = null;
      String[] rowValue;
      try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputFile.open()))) {
        for (int rowIndex = 0; rowIndex < conf.getSampleSize() && (line = reader.readLine()) != null; rowIndex++) {
          rowValue = line.split(delimiter, -1);
          if (rowIndex == 0) {
            columnNames = DataTypeDetectorUtils.setColumnNames(line, conf.getSkipHeader(), conf.getEnableQuotedValues(),
                                                               delimiter);
            if (conf.getSkipHeader()) {
              continue;
            }
          }
          DataTypeDetectorUtils.detectDataTypeOfRowValues(conf.getOverride(), dataTypeDetectorStatusKeeper, columnNames,
                                                          rowValue);
        }
        dataTypeDetectorStatusKeeper.validateDataTypeDetector();
      }
      List<Schema.Field> fields = DataTypeDetectorUtils.detectDataTypeOfEachDatasetColumn(
        conf.getOverride(), columnNames, dataTypeDetectorStatusKeeper);
      Schema schema = Schema.recordOf("text", fields);
      return PathTrackingInputFormatProvider.addPathField(context.getFailureCollector(), schema, conf.getPathField());
    }
    return null;
  }

  /**
   * Plugin config for delimited input format
   */
  public static class Conf extends DelimitedConfig {
    private static final String DELIMITER = "delimiter";
    private static final String DELIMITER_DESC = "Delimiter to use to separate record fields.";

    @Macro
    @Nullable
    @Description(DELIMITER_DESC)
    private String delimiter;

    public Conf() {
      this(null);
    }

    public Conf(@Nullable String delimiter) {
      this.delimiter = delimiter;
    }

    @VisibleForTesting
    public Conf(@Nullable String delimiter, String pathField) {
      this.delimiter = delimiter;
      this.pathField = pathField;
    }
  }

  private static PluginClass getPluginClass() {
    Map<String, PluginPropertyField> properties = new HashMap<>(DelimitedConfig.DELIMITED_FIELDS);
    properties.put("delimiter", new PluginPropertyField("delimiter", Conf.DELIMITER_DESC, "string", false, true));
    return new PluginClass(ValidatingInputFormat.PLUGIN_TYPE, NAME, DESC, DelimitedInputFormatProvider.class.getName(),
      "conf", properties);
  }
}
