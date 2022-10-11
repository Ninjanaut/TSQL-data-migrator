create function [migrator].[CompareSchemaAnyTables] 
(
	@sourceLinkedServer nvarchar(128),
	@sourceDatabase nvarchar(128),
	@targetLinkedServer nvarchar(128),
	@targetDatabase nvarchar(128),
	@tables [migrator].[Tables] readonly
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

	insert into @result
	select diff.*
	from @tables 
	cross apply (
		select migrator.GetTableNameFromParts(@sourceLinkedServer, @sourceDatabase, SchemaName, TableName) as [Table]
	) [source]
	cross apply (
		select migrator.GetTableNameFromParts(@targetLinkedServer, @targetDatabase, SchemaName, TableName) as [Table]
	) [target]
	cross apply migrator.CompareSchemaTwoTables([source].[Table], [target].[Table]) diff

	return
end