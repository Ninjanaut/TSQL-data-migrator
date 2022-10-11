/****** Object:  UserDefinedTableType [migrator].[TableSchemaDifference]    Script Date: 2022-10-08 9:27:58 AM ******/
CREATE TYPE [migrator].[TableSchemaDifference] AS TABLE(
	[source_table_name] [nvarchar](512) NULL,
	[source_column_name] [nvarchar](128) NULL,
	[source_system_type_name] [nvarchar](128) NULL,
	[source_is_nullable] [bit] NULL,
	[target_table_name] [nvarchar](512) NULL,
	[target_column_name] [nvarchar](128) NULL,
	[target_system_type_name] [nvarchar](128) NULL,
	[target_is_nullable] [bit] NULL
)