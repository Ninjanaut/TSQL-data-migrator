/****** Object:  UserDefinedTableType [migrator].[Tables]    Script Date: 2022-10-08 9:27:58 AM ******/
CREATE TYPE [migrator].[Tables] AS TABLE(
	[SchemaName] [nvarchar](128) NULL,
	[TableName] [nvarchar](128) NULL
)