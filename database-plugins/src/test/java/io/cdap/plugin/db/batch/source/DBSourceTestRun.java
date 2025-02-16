/*
 * Copyright © 2015-2019 Cask Data, Inc.
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

package io.cdap.plugin.db.batch.source;

import com.google.common.collect.ImmutableMap;
import io.cdap.cdap.api.common.Bytes;
import io.cdap.cdap.api.data.format.StructuredRecord;
import io.cdap.cdap.api.dataset.table.Table;
import io.cdap.cdap.etl.api.batch.BatchSource;
import io.cdap.cdap.etl.mock.batch.MockSink;
import io.cdap.cdap.etl.proto.v2.ETLBatchConfig;
import io.cdap.cdap.etl.proto.v2.ETLPlugin;
import io.cdap.cdap.etl.proto.v2.ETLStage;
import io.cdap.cdap.proto.artifact.AppRequest;
import io.cdap.cdap.proto.id.ApplicationId;
import io.cdap.cdap.proto.id.NamespaceId;
import io.cdap.cdap.test.ApplicationManager;
import io.cdap.cdap.test.DataSetManager;
import io.cdap.plugin.ConnectionConfig;
import io.cdap.plugin.DBConfig;
import io.cdap.plugin.DatabasePluginTestBase;
import io.cdap.plugin.common.Constants;
import io.cdap.plugin.db.common.FQNGenerator;
import org.junit.Assert;
import org.junit.Test;

import java.math.BigDecimal;
import java.math.MathContext;
import java.nio.ByteBuffer;
import java.sql.Date;
import java.sql.Time;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Test for ETL using databases.
 */
public class DBSourceTestRun extends DatabasePluginTestBase {

  @Test
  @SuppressWarnings("ConstantConditions")
  public void testDBMacroSupport() throws Exception {
    String importQuery = "SELECT * FROM \"my_table\" WHERE DATE_COL <= '${logicalStartTime(yyyy-MM-dd,1d)}' " +
      "AND $CONDITIONS";
    String boundingQuery = "SELECT MIN(ID),MAX(ID) from \"my_table\"";
    String splitBy = "ID";
    ETLPlugin sourceConfig = new ETLPlugin(
      "Database",
      BatchSource.PLUGIN_TYPE,
      ImmutableMap.<String, String>builder()
        .put(ConnectionConfig.CONNECTION_STRING, getConnectionURL())
        .put(DBSource.DBSourceConfig.IMPORT_QUERY, importQuery)
        .put(DBSource.DBSourceConfig.BOUNDING_QUERY, boundingQuery)
        .put(DBSource.DBSourceConfig.SPLIT_BY, splitBy)
        .put(DBSource.DBSourceConfig.FETCH_SIZE, "${db.fetch.size}")
        .put(ConnectionConfig.JDBC_PLUGIN_NAME, "hypersql")
        .put(Constants.Reference.REFERENCE_NAME, "DBMacroTest")
        .build(),
      null
    );

    ETLPlugin sinkConfig = MockSink.getPlugin("macroOutputTable");

    ApplicationManager appManager = deployETL(sourceConfig, sinkConfig, "testDBMacro");
    runETLOnce(appManager, ImmutableMap.of("logical.start.time", String.valueOf(CURRENT_TS),
                                           "db.fetch.size", Integer.toString(100)));

    DataSetManager<Table> outputManager = getDataset("macroOutputTable");
    Assert.assertTrue(MockSink.readOutput(outputManager).isEmpty());
  }

  @Test
  @SuppressWarnings("ConstantConditions")
  public void testDBSource() throws Exception {
    String importQuery = "SELECT ID, NAME, SCORE, GRADUATED, TINY, SMALL, BIG, FLOAT_COL, REAL_COL, NUMERIC_COL, " +
      "DECIMAL_COL, BIT_COL, DATE_COL, TIME_COL, TIMESTAMP_COL, BINARY_COL, LONGVARBINARY_COL, BLOB_COL, " +
      "CLOB_COL, CHAR_COL, LONGVARCHAR_COL, VARBINARY_COL FROM \"my_table\" " +
      "WHERE ID < 3 AND $CONDITIONS";
    String boundingQuery = "SELECT MIN(ID),MAX(ID) from \"my_table\"";
    String splitBy = "ID";
    ETLPlugin sourceConfig = new ETLPlugin(
      "Database",
      BatchSource.PLUGIN_TYPE,
      ImmutableMap.<String, String>builder()
        .put(DBConfig.CONNECTION_STRING, getConnectionURL())
        .put(DBSource.DBSourceConfig.IMPORT_QUERY, importQuery)
        .put(DBSource.DBSourceConfig.BOUNDING_QUERY, boundingQuery)
        .put(DBSource.DBSourceConfig.SPLIT_BY, splitBy)
        .put(DBConfig.JDBC_PLUGIN_NAME, "hypersql")
        .put(Constants.Reference.REFERENCE_NAME, "DBSourceTest")
        .build(),
      null
    );

    String outputDatasetName = "output-dbsourcetest";
    ETLPlugin sinkConfig = MockSink.getPlugin(outputDatasetName);

    ApplicationManager appManager = deployETL(sourceConfig, sinkConfig, "testDBSource");
    runETLOnce(appManager);

    DataSetManager<Table> outputManager = getDataset(outputDatasetName);
    List<StructuredRecord> outputRecords = MockSink.readOutput(outputManager);

    Assert.assertEquals(2, outputRecords.size());
    String userid = outputRecords.get(0).get("NAME");
    StructuredRecord row1 = "user1".equals(userid) ? outputRecords.get(0) : outputRecords.get(1);
    StructuredRecord row2 = "user1".equals(userid) ? outputRecords.get(1) : outputRecords.get(0);

    // Verify data
    Assert.assertEquals("user1", row1.get("NAME"));
    Assert.assertEquals("user2", row2.get("NAME"));
    Assert.assertEquals("longvarchar1", row1.get("LONGVARCHAR_COL"));
    Assert.assertEquals("longvarchar2", row2.get("LONGVARCHAR_COL"));
    Assert.assertEquals("char1", ((String) row1.get("CHAR_COL")).trim());
    Assert.assertEquals("char2", ((String) row2.get("CHAR_COL")).trim());
    Assert.assertEquals(124.45, row1.get("SCORE"), 0.000001);
    Assert.assertEquals(125.45, row2.get("SCORE"), 0.000001);
    Assert.assertEquals(false, row1.get("GRADUATED"));
    Assert.assertEquals(true, row2.get("GRADUATED"));
    Assert.assertNull(row1.get("NOT_IMPORTED"));
    Assert.assertNull(row2.get("NOT_IMPORTED"));
    // TODO: Reading from table as SHORT seems to be giving the wrong value.
    Assert.assertEquals(1, (int) row1.get("TINY"));
    Assert.assertEquals(2, (int) row2.get("TINY"));
    Assert.assertEquals(1, (int) row1.get("SMALL"));
    Assert.assertEquals(2, (int) row2.get("SMALL"));
    Assert.assertEquals(1, (long) row1.get("BIG"));
    Assert.assertEquals(2, (long) row2.get("BIG"));
    // TODO: Reading from table as FLOAT seems to be giving back the wrong value.
    Assert.assertEquals(124.45, row1.get("FLOAT_COL"), 0.00001);
    Assert.assertEquals(125.45, row2.get("FLOAT_COL"), 0.00001);
    Assert.assertEquals(124.45, row1.get("REAL_COL"), 0.00001);
    Assert.assertEquals(125.45, row2.get("REAL_COL"), 0.00001);
    Assert.assertEquals(new BigDecimal(124.45, new MathContext(5)).setScale(2),
                        row1.getDecimal("NUMERIC_COL"));
    Assert.assertEquals(new BigDecimal(125.45, new MathContext(5)).setScale(2),
                        row2.getDecimal("NUMERIC_COL"));
    Assert.assertEquals(new BigDecimal(124.45, new MathContext(5)).setScale(2),
                        row1.getDecimal("DECIMAL_COL"));
    Assert.assertNull(row2.getDecimal("DECIMAL_COL"));
    Assert.assertTrue(row1.get("BIT_COL"));
    Assert.assertFalse(row2.get("BIT_COL"));
    // Verify time columns
    java.util.Date date = new java.util.Date(CURRENT_TS);
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    LocalDate expectedDate = Date.valueOf(sdf.format(date)).toLocalDate();
    sdf = new SimpleDateFormat("H:mm:ss");
    LocalTime expectedTime = Time.valueOf(sdf.format(date)).toLocalTime();
    ZonedDateTime expectedTs = date.toInstant().atZone(ZoneId.ofOffset("UTC", ZoneOffset.UTC));
    Assert.assertEquals(expectedDate, row1.getDate("DATE_COL"));
    Assert.assertEquals(expectedTime, row1.getTime("TIME_COL"));
    Assert.assertEquals(expectedTs, row1.getTimestamp("TIMESTAMP_COL", ZoneId.ofOffset("UTC", ZoneOffset.UTC)));

    // verify binary columns
    Assert.assertEquals("user1", Bytes.toString(((ByteBuffer) row1.get("BINARY_COL")).array(), 0, 5));
    Assert.assertEquals("user2", Bytes.toString(((ByteBuffer) row2.get("BINARY_COL")).array(), 0, 5));
    Assert.assertEquals("user1", Bytes.toString(((ByteBuffer) row1.get("LONGVARBINARY_COL")).array(), 0, 5));
    Assert.assertEquals("user2", Bytes.toString(((ByteBuffer) row2.get("LONGVARBINARY_COL")).array(), 0, 5));
    Assert.assertEquals("user1", Bytes.toString(((ByteBuffer) row1.get("VARBINARY_COL")).array(), 0, 5));
    Assert.assertEquals("user2", Bytes.toString(((ByteBuffer) row2.get("VARBINARY_COL")).array(), 0, 5));
    Assert.assertEquals("user1", Bytes.toString(((ByteBuffer) row1.get("BLOB_COL")).array(), 0, 5));
    Assert.assertEquals("user2", Bytes.toString(((ByteBuffer) row2.get("BLOB_COL")).array(), 0, 5));
    Assert.assertEquals(CLOB_DATA, row1.get("CLOB_COL"));
    Assert.assertEquals(CLOB_DATA, row2.get("CLOB_COL"));
  }

  @Test
  public void testBackwardCompatibilityForSQLDataTypes() throws Exception {
    String importQuery = "SELECT ID, NAME, DECIMAL_INT, DECIMAL_COL, DECIMAL_LONG, NUMERIC_INT, NUMERIC_COL," +
      " NUMERIC_LONG FROM \"my_table\" WHERE ID < 3 AND $CONDITIONS";

    String boundingQuery = "SELECT MIN(ID),MAX(ID) from \"my_table\"";
    String splitBy = "ID";
    ETLPlugin sourceConfig = new ETLPlugin(
      "Database",
      BatchSource.PLUGIN_TYPE,
      ImmutableMap.<String, String>builder()
        .put(DBConfig.CONNECTION_STRING, getConnectionURL())
        .put(DBSource.DBSourceConfig.IMPORT_QUERY, importQuery)
        .put(DBSource.DBSourceConfig.BOUNDING_QUERY, boundingQuery)
        .put(DBSource.DBSourceConfig.SPLIT_BY, splitBy)
        .put(DBConfig.JDBC_PLUGIN_NAME, "hypersql")
        .put(Constants.Reference.REFERENCE_NAME, "DBSourceTestBackwardsCompatibility")
        .put("schema", " {\n" +
          "            \"type\": \"record\",\n" +
          "            \"name\": \"etlSchemaBody\",\n" +
          "            \"fields\": [\n" +
          "                {\n" +
          "                    \"name\": \"ID\",\n" +
          "                    \"type\": \"int\"\n" +
          "                },\n" +
          "                {\n" +
          "                    \"name\": \"NAME\",\n" +
          "                    \"type\": \"string\"\n" +
          "                },\n" +
          "                {\n" +
          "                    \"name\": \"DECIMAL_INT\",\n" +
          "                    \"type\": \"int\"\n" +
          "                },\n" +
          "                 {\n" +
          "                    \"name\": \"DECIMAL_COL\",\n" +
          "                    \"type\": [ \"double\" , \"null\" ]\n" +
          "                },\n" +
          "                {\n" +
          "                    \"name\": \"DECIMAL_LONG\",\n" +
          "                    \"type\": \"long\"\n" +
          "                },\n" +
          "                {\n" +
          "                    \"name\": \"NUMERIC_INT\",\n" +
          "                    \"type\": \"int\"\n" +
          "                },\n" +
          "                {\n" +
          "                    \"name\": \"NUMERIC_COL\",\n" +
          "                    \"type\": [ \"double\" , \"null\" ]\n" +
          "                },\n" +
          "                {\n" +
          "                    \"name\": \"NUMERIC_LONG\",\n" +
          "                    \"type\": \"long\"\n" +
          "                }\n" +
          "            ]\n" +
          "}")
        .build(),
      null
    );
    String outputDatasetName = "output-dbsourcetestcompatibility";
    ETLPlugin sinkConfig = MockSink.getPlugin(outputDatasetName);
    ApplicationManager appManager = deployETL(sourceConfig, sinkConfig, "testDBSourceCompatibility");
    runETLOnce(appManager);
    DataSetManager<Table> outputManager = getDataset(outputDatasetName);
    List<StructuredRecord> outputRecords = MockSink.readOutput(outputManager);
    Assert.assertEquals(2, outputRecords.size());
    String userid = outputRecords.get(0).get("NAME");
    StructuredRecord row1 = "user1".equals(userid) ? outputRecords.get(0) : outputRecords.get(1);
    StructuredRecord row2 = "user1".equals(userid) ? outputRecords.get(1) : outputRecords.get(0);
    Assert.assertEquals(124, (int) row1.get("DECIMAL_INT"));
    Assert.assertEquals(124.45, row1.get("DECIMAL_COL"), 0.000001);
    Assert.assertNull(row2.get("DECIMAL_COL"));
    Assert.assertEquals(1000000000, (long) row1.get("DECIMAL_LONG"));
  }

  @Test
  public void testDBSourceWithLowerCaseColNames() throws Exception {
    String importQuery = "SELECT ID, NAME FROM \"my_table\" WHERE ID < 3 AND $CONDITIONS";
    String boundingQuery = "SELECT MIN(ID),MAX(ID) from \"my_table\"";
    String splitBy = "ID";
    ETLPlugin sourceConfig = new ETLPlugin(
      "Database",
      BatchSource.PLUGIN_TYPE,
      ImmutableMap.<String, String>builder()
        .put(DBConfig.CONNECTION_STRING, getConnectionURL())
        .put(DBSource.DBSourceConfig.IMPORT_QUERY, importQuery)
        .put(DBSource.DBSourceConfig.BOUNDING_QUERY, boundingQuery)
        .put(DBSource.DBSourceConfig.SPLIT_BY, splitBy)
        .put(DBConfig.JDBC_PLUGIN_NAME, "hypersql")
        .put(DBConfig.COLUMN_NAME_CASE, "lower")
        .put(Constants.Reference.REFERENCE_NAME, "DBLowerCaseTest")
        .build(),
      null
    );

    String outputDatasetName = "output-lowercasetest";
    ETLPlugin sinkConfig = MockSink.getPlugin(outputDatasetName);

    ApplicationManager appManager = deployETL(sourceConfig, sinkConfig, "testDBSourceWithLowerCase");
    runETLOnce(appManager);

    // records should be written
    DataSetManager<Table> outputManager = getDataset(outputDatasetName);
    List<StructuredRecord> outputRecords = MockSink.readOutput(outputManager);
    Assert.assertEquals(2, outputRecords.size());
    String userid = outputRecords.get(0).get("name");
    StructuredRecord row1 = "user1".equals(userid) ? outputRecords.get(0) : outputRecords.get(1);
    StructuredRecord row2 = "user1".equals(userid) ? outputRecords.get(1) : outputRecords.get(0);
    // Verify data
    Assert.assertEquals("user1", row1.get("name"));
    Assert.assertEquals("user2", row2.get("name"));
    Assert.assertEquals(1, row1.<Integer>get("id").intValue());
    Assert.assertEquals(2, row2.<Integer>get("id").intValue());
  }

  @Test
  public void testDbSourceMultipleTables() throws Exception {
    // have the same data in both tables ('\"my_table\"' and '\"your_table\"'), and select the ID and NAME fields from
    // separate tables
    String importQuery = "SELECT \"my_table\".ID, \"your_table\".NAME FROM \"my_table\", \"your_table\"" +
      "WHERE \"my_table\".ID < 3 and \"my_table\".ID = \"your_table\".ID and $CONDITIONS";
    String boundingQuery = "SELECT MIN(MIN(\"my_table\".ID), MIN(\"your_table\".ID)), " +
      "MAX(MAX(\"my_table\".ID), MAX(\"your_table\".ID))";
    String splitBy = "\"my_table\".ID";
    ETLPlugin sourceConfig = new ETLPlugin(
      "Database",
      BatchSource.PLUGIN_TYPE,
      ImmutableMap.<String, String>builder()
        .put(DBConfig.CONNECTION_STRING, getConnectionURL())
        .put(DBSource.DBSourceConfig.IMPORT_QUERY, importQuery)
        .put(DBSource.DBSourceConfig.BOUNDING_QUERY, boundingQuery)
        .put(DBSource.DBSourceConfig.SPLIT_BY, splitBy)
        .put(DBConfig.JDBC_PLUGIN_NAME, "hypersql")
        .put(Constants.Reference.REFERENCE_NAME, "DBMultipleTest")
        .build(),
      null
    );

    String outputDatasetName = "output-multitabletest";
    ETLPlugin sinkConfig = MockSink.getPlugin(outputDatasetName);

    ApplicationManager appManager = deployETL(sourceConfig, sinkConfig, "testDBSourceWithMultipleTables");
    runETLOnce(appManager);

    // records should be written
    DataSetManager<Table> outputManager = getDataset(outputDatasetName);
    List<StructuredRecord> outputRecords = MockSink.readOutput(outputManager);
    Assert.assertEquals(2, outputRecords.size());
    String userid = outputRecords.get(0).get("NAME");
    StructuredRecord row1 = "user1".equals(userid) ? outputRecords.get(0) : outputRecords.get(1);
    StructuredRecord row2 = "user1".equals(userid) ? outputRecords.get(1) : outputRecords.get(0);
    // Verify data
    Assert.assertEquals("user1", row1.get("NAME"));
    Assert.assertEquals("user2", row2.get("NAME"));
    Assert.assertEquals(1, row1.<Integer>get("ID").intValue());
    Assert.assertEquals(2, row2.<Integer>get("ID").intValue());
  }

  @Test
  public void testUserNamePasswordCombinations() throws Exception {
    String importQuery = "SELECT * FROM \"my_table\" WHERE $CONDITIONS";
    String boundingQuery = "SELECT MIN(ID),MAX(ID) from \"my_table\"";
    String splitBy = "ID";

    ETLPlugin sinkConfig = MockSink.getPlugin("outputTable");

    Map<String, String> baseSourceProps = ImmutableMap.<String, String>builder()
      .put(DBConfig.CONNECTION_STRING, getConnectionURL())
      .put(DBConfig.JDBC_PLUGIN_NAME, "hypersql")
      .put(DBSource.DBSourceConfig.IMPORT_QUERY, importQuery)
      .put(DBSource.DBSourceConfig.BOUNDING_QUERY, boundingQuery)
      .put(DBSource.DBSourceConfig.SPLIT_BY, splitBy)
      .put(Constants.Reference.REFERENCE_NAME, "UserPassDBTest")
      .build();

    ApplicationId appId = NamespaceId.DEFAULT.app("dbTest");

    // null user name, null password. Should succeed.
    // as source
    ETLPlugin dbConfig = new ETLPlugin("Database", BatchSource.PLUGIN_TYPE, baseSourceProps, null);
    ETLStage table = new ETLStage("uniqueTableSink" , sinkConfig);
    ETLStage database = new ETLStage("databaseSource" , dbConfig);
    ETLBatchConfig etlConfig = ETLBatchConfig.builder()
      .addStage(database)
      .addStage(table)
      .addConnection(database.getName(), table.getName())
      .build();
    AppRequest<ETLBatchConfig> appRequest = new AppRequest<>(DATAPIPELINE_ARTIFACT, etlConfig);
    deployApplication(appId, appRequest);

    // null user name, non-null password. Should fail.
    // as source
    Map<String, String> noUser = new HashMap<>(baseSourceProps);
    noUser.put(DBConfig.PASSWORD, "password");
    database = new ETLStage("databaseSource", new ETLPlugin("Database", BatchSource.PLUGIN_TYPE, noUser, null));
    etlConfig = ETLBatchConfig.builder()
      .addStage(database)
      .addStage(table)
      .addConnection(database.getName(), table.getName())
      .build();
    assertDeploymentFailure(
      appId, etlConfig, "Deploying DB Source with null username but non-null password should have failed.");

    // non-null username, non-null, but empty password. Should succeed.
    // as source
    Map<String, String> emptyPassword = new HashMap<>(baseSourceProps);
    emptyPassword.put(DBConfig.USER, "emptyPwdUser");
    emptyPassword.put(DBConfig.PASSWORD, "");
    database = new ETLStage("databaseSource", new ETLPlugin("Database", BatchSource.PLUGIN_TYPE, emptyPassword, null));
    etlConfig = ETLBatchConfig.builder()
      .addStage(database)
      .addStage(table)
      .addConnection(database.getName(), table.getName())
      .build();
    appRequest = new AppRequest<>(DATAPIPELINE_ARTIFACT, etlConfig);
    deployApplication(appId, appRequest);
  }

  @Test
  public void testNonExistentDBTable() throws Exception {
    // source
    String importQuery = "SELECT ID, NAME FROM dummy WHERE ID < 3 AND $CONDITIONS";
    String boundingQuery = "SELECT MIN(ID),MAX(ID) FROM dummy";
    String splitBy = "ID";
    //TODO: Also test for bad connection:
    ETLPlugin sinkConfig = MockSink.getPlugin("table");
    ETLPlugin sourceBadNameConfig = new ETLPlugin(
      "Database",
      BatchSource.PLUGIN_TYPE,
      ImmutableMap.<String, String>builder()
        .put(DBConfig.CONNECTION_STRING, getConnectionURL())
        .put(DBSource.DBSourceConfig.IMPORT_QUERY, importQuery)
        .put(DBSource.DBSourceConfig.BOUNDING_QUERY, boundingQuery)
        .put(DBConfig.JDBC_PLUGIN_NAME, "hypersql")
        .put(DBSource.DBSourceConfig.SPLIT_BY, splitBy)
        .put(Constants.Reference.REFERENCE_NAME, "DBNonExistentTest")
        .build(),
      null);
    ETLStage sink = new ETLStage("sink", sinkConfig);
    ETLStage sourceBadName = new ETLStage("sourceBadName", sourceBadNameConfig);

    ETLBatchConfig etlConfig = ETLBatchConfig.builder()
      .addStage(sourceBadName)
      .addStage(sink)
      .addConnection(sourceBadName.getName(), sink.getName())
      .build();
    ApplicationId appId = NamespaceId.DEFAULT.app("dbSourceNonExistingTest");
    assertDeploymentFailure(appId, etlConfig, "ETL Application with DB Source should have failed because of a " +
      "non-existent source table.");

    // Bad connection
    String badConnection = String.format("jdbc:hsqldb:hsql://localhost/%sWRONG", getDatabase());
    ETLPlugin sourceBadConnConfig = new ETLPlugin(
      "Database",
      BatchSource.PLUGIN_TYPE,
      ImmutableMap.<String, String>builder()
        .put(DBConfig.CONNECTION_STRING, badConnection)
        .put(DBSource.DBSourceConfig.IMPORT_QUERY, importQuery)
        .put(DBSource.DBSourceConfig.BOUNDING_QUERY, boundingQuery)
        .put(DBConfig.JDBC_PLUGIN_NAME, "hypersql")
        .put(DBSource.DBSourceConfig.SPLIT_BY, splitBy)
        .put(Constants.Reference.REFERENCE_NAME, "HSQLDBTest")
        .build(),
      null);
    ETLStage sourceBadConn = new ETLStage("sourceBadConn", sourceBadConnConfig);
    etlConfig = ETLBatchConfig.builder()
      .addStage(sourceBadConn)
      .addStage(sink)
      .addConnection(sourceBadConn.getName(), sink.getName())
      .build();
    assertDeploymentFailure(appId, etlConfig, "ETL Application with DB Source should have failed because of a " +
      "non-existent source database.");
  }

  @Test
  public void testMySQLFQN() throws Exception {
    // Testcases consist of Connection URL, Table Name, Expected FQN String
    String[][] testCases  = {{"jdbc:mysql://localhost:1111/db", "table1", "mysql://localhost:1111/db.table1"},
                             {"jdbc:mysql://34.35.36.37/db?useSSL=false", "table2",
                               "mysql://34.35.36.37:3306/db.table2"}};
    for (int i = 0; i < testCases.length; i++) {
      String fqn = FQNGenerator.constructFQN(testCases[i][0], testCases[i][1]);
      Assert.assertEquals(testCases[i][2], fqn);
    }
  }

  @Test
  public void testSQLServerFQN() throws Exception {
    // Testcases consist of Connection URL, Table Name, Expected FQN String
    String[][] testCases  = {{"jdbc:sqlserver://;serverName=127.0.0.1;databaseName=DB",
                               "table1", "sqlserver://127.0.0.1:1433/DB.table1"},
                             {"jdbc:sqlserver://localhost:1111;databaseName=DB;encrypt=true;user=user;password=pwd;",
                               "table2", "sqlserver://localhost:1111/DB.table2"}};
    for (int i = 0; i < testCases.length; i++) {
      String fqn = FQNGenerator.constructFQN(testCases[i][0], testCases[i][1]);
      Assert.assertEquals(testCases[i][2], fqn);
    }
  }

  @Test
  public void testOracleFQN() throws Exception {
    // Testcases consist of Connection URL, Table Name, Expected FQN String
    String[][] testCases  = {{"jdbc:oracle:thin:@localhost:db", "table1", "oracle://localhost:1521/db.table1"},
                             {"jdbc:oracle:thin:@test.server:1111/db",
                               "table2", "oracle://test.server:1111/db.table2"}};
    for (int i = 0; i < testCases.length; i++) {
      String fqn = FQNGenerator.constructFQN(testCases[i][0], testCases[i][1]);
      Assert.assertEquals(testCases[i][2], fqn);
    }
  }

  @Test
  public void testPostgresqlFQN() throws Exception {
    // Testcases consist of Connection URL, Table Name, Expected FQN String
    String[][] testCases  = {{"jdbc:postgresql://34.35.36.37/test?user=user&password=secret&ssl=true",
                              "table1", "postgresql://34.35.36.37:5432/test.public.table1"},
                            {"jdbc:postgresql://localhost/test?connectionSchema=schema",
                              "table2", "postgresql://localhost:5432/test.schema.table2"},
                            {"jdbc:postgresql://localhost/test?searchpath=schema",
                              "table3", "postgresql://localhost:5432/test.schema.table3"}};
    for (int i = 0; i < testCases.length; i++) {
      String fqn = FQNGenerator.constructFQN(testCases[i][0], testCases[i][1]);
      Assert.assertEquals(testCases[i][2], fqn);
    }
  }
}
