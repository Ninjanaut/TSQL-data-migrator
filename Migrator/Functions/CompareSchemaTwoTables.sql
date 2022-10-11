-- Usage example:
-- insert into @tables values ('SourceLinkedServer.Database.schema.Table', 'TargetTable')
-- select diff.* from @tables t
-- cross apply migrator.CompareSchemaForTwoTables(t.SourceTableName, t.TargetTableName) diff
CREATE function [migrator].[CompareSchemaTwoTables] 
(
	-- MAX_OWNER_NAME_LENGTH is 128 characters. 
	-- Therefore max linked server + database + schema + table name length is 512 characters.
	@sourceTableName nvarchar(512), 
	@targetTableName nvarchar(512)
)
returns @result table
(
	source_table_name nvarchar(512),
    source_column_name nvarchar(128),
    source_system_type_name nvarchar(128),
	source_is_nullable bit,
	target_table_name nvarchar(512),
	target_column_name nvarchar(128),
    target_system_type_name nvarchar(128),
	target_is_nullable bit
)
as 
begin

	-- Parameter guard
	declare @sourceTableNullOrEmpty bit = case when @sourceTableName = '' or @sourceTableName is null then 1 else 0 end
	declare @targetTableNullOrEmpty bit = case when @targetTableName = '' or @targetTableName is null then 1 else 0 end
	if (@sourceTableNullOrEmpty = 1 and @targetTableNullOrEmpty = 1) return

	insert into @result 
	select

	@sourceTableName as source_table_name,
	[source].[name] as source_column_name,
	[source].[system_type_name] as source_system_type_name, 
	[source].[is_nullable] as source_is_nullable, 

	@targetTableName as target_table_name,
	[target].[name] as target_column_name,
	[target].[system_type_name] as target_system_type_name,
	[target].[is_nullable] as target_is_nullable

	from sys.dm_exec_describe_first_result_set (N'select top 1 * from ' + @sourceTableName, NULL, 0) [source]
	full join  sys.dm_exec_describe_first_result_set (N'select top 1 * from ' + @targetTableName, NULL, 0) [target] 
	on [source].[name] = [target].[name]

	where
	(
		(
		   [source].[is_nullable] != [target].[is_nullable]
		-- Fix the situation when sys.dm_exec_describe_first_result_set returns numeric instead of decimal when using linked server.
		or replace([source].[system_type_name], 'numeric','decimal') != replace([target].[system_type_name], 'numeric','decimal')
		or [source].[max_length] != [target].[max_length]
		or [source].[precision] != [target].[precision]
		or [source].[scale] != [target].[scale]
		) 
		or 
		(
			[source].[name] is null 
		and [target].[name] is not null
		) 
		or 
		(
			[source].[name] is not null 
		and [target].[name] is null
		)
	) 
	-- Fix the situation when sys.dm_exec_describe_first_result_set returns datetime instead of smalldatetime when using linked server.
	and replace([source].[system_type_name], 'smalldeatetime','datetime') != replace([target].[system_type_name], 'smalldatetime','datetime')

	return
end