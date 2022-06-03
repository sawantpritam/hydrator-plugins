/*
 * Copyright © 2022 Cask Data, Inc.
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

package io.cdap.plugin.lookup.stepsdesign;

import io.cdap.e2e.utils.BigQueryClient;
import io.cdap.e2e.utils.CdfHelper;
import io.cdap.e2e.utils.PluginPropertyUtils;
import io.cdap.plugin.lookup.actions.LookUpActions;
import io.cucumber.java.en.Then;
import org.apache.commons.lang.StringUtils;
import org.junit.Assert;
import java.io.IOException;
import java.util.Optional;

/**
 * LookUp plugin related Stepsdesign
 */

public class LookUp implements CdfHelper {

  @Then("Press ESC key to close the Lookup dataset dropdown")
  public void pressESCKeyToCloseTheLookupDatasetDropdown() {
    LookUpActions.pressEscapeKey();
  }

  @Then("Verify columnList: {string} of target BigQuery table: {string}")
  public void verifyColumnListOfTargetBigQueryTable(String columnList, String tableName) throws IOException,
    InterruptedException {
    String[] columnNames = PluginPropertyUtils.pluginProp(columnList).split(",");
    for (String column : columnNames) {
      Optional<String> result = BigQueryClient
        .getSoleQueryResult("SELECT column_name FROM `" + (PluginPropertyUtils.pluginProp("projectId")) + "."
                              + (PluginPropertyUtils.pluginProp("dataset")) + ".INFORMATION_SCHEMA.COLUMNS` " +
                              "WHERE table_name = '" + PluginPropertyUtils.pluginProp(tableName)
                              + "' and column_name = '" + column + "' ");
      String targetTableColumnName = StringUtils.EMPTY;
      if (result.isPresent()) {
        targetTableColumnName = result.get();
      }
      Assert.assertTrue("Column '" + column + "' should present in target BigQuery table",
                        targetTableColumnName.equalsIgnoreCase(column));
    }
  }
}
