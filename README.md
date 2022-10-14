# TSQL-data-migrator

A procedure that allows you to easily copy tables data from one database to another. 

### Procedure
* Determines the order of dependencies between tables, so there is no need to recreate foreign keys. 
* Does not recreate the target tables, so the structure and permissions will not change.
* Handles computed columns.
* Supports usage of linked server for the source database.
* Uses TABLOCK on an insert for source and target table for better performance.
* Correctly reseeds tables even for newly created tables.
* Checks whether the source and target tables exists and their structure matches.
  * The structure differences will display in the query window.
* Input parameters are guarded with QUOTENAME function to prevent SQL injection.
* You can use this code for commercial use.

### Solution
* Contains two projects
  * SSDT SQL Server Database project
  * xUnit test project
* You can install migrator directly from the `Scripts/migrator-installation.sql`
  * Everything is installed into `migrator` schema

### Usage
```sql
declare @tables as migrator.[Tables];

insert into @tables (SchemaName, TableName) values
('dbo', 'TableOne'), 
('dbo', 'TableTwo'), 
('dbo', 'TableThree'), 
('dbo', 'TableFour'), 
('dbo', 'TableFive')

exec migrator.[CopyTables] @sourceLinkedServer, @sourceDatabase, @targetDatabase, @tables
```

There are other helper procedures and functions that are used in the background and can be used directly

### Functions
`migrator.GetDatabaseNameFromParts` 

`migrator.GetTableNameFromParts`

`migrator.CompareSchemaAnyTables`

`migrator.CompareSchemaTwoTables`

### Procedures
`migrator.CopyTables`

`migrator.CopyTable`

`migrator.DeleteAndReseedTable`

`migrator.EnsureTableExists`

`migrator.GetTableColumnsAsCsv`

`migrator.IsNewTableWithoutHistoricalIdentityValue`

### Possible future features
* Check that the provided tables form a complete dependency chain.
  * And displays missing tables.
* Allow to specify no table in input and try to copy all tables that exist in the source or target database.

### Contribution
* In case you would like to contribute, please send pull request to `develop` branch.

### Feedback
* Please let me know what do you think or if you used the code.