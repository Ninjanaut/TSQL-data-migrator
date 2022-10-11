CREATE SCHEMA [migrator]
GO

CREATE TYPE [migrator].[Tables] AS TABLE(
	[SchemaName] [nvarchar](128) NULL,
	[TableName] [nvarchar](128) NULL
)
GO

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
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [migrator].[CompareSchemaAnyTables] 
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
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [migrator].[CompareSchemaTwoTables] 
(
	-- MAX_OWNER_NAME_LENGTH is 128 characters.
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
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [migrator].[GetDatabaseNameFromParts] 
(
	@linkedServer nvarchar(128),
	@database nvarchar(128)
)
returns nvarchar(256)
as
begin
	declare @result nvarchar(255) = null;

	-- Add database name
	if (@database is null or @database = '') 
		return @result

	set @result = QUOTENAME(@database)

	-- Add linked server name
	if (@linkedServer is null or @linkedServer = '') 
		return @result

	set @result = QUOTENAME(@linkedServer) + '.' + @result

	-- Return full object name
	return @result
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [migrator].[GetTableNameFromParts] 
(
	@linkedServer nvarchar(128),
	@database nvarchar(128),
	@schema nvarchar(128),
	@table nvarchar(128)
)
returns nvarchar(512)
as
begin
	declare @result nvarchar(255) = null;

	-- Add table name
	if (@table is null or @table = '') 
		return @result

	set @result = QUOTENAME(@table)
	
	-- Add schema name
	if (@schema is null or @schema = '') 
		return @result

	set @result = QUOTENAME(@schema) + '.' + @result

	-- Add database name
	if (@database is null or @database = '') 
		return @result

	set @result = QUOTENAME(@database) + '.' + @result

	-- Add linked server name
	if (@linkedServer is null or @linkedServer = '') 
		return @result

	set @result = QUOTENAME(@linkedServer) + '.' + @result

	-- Return full object name
	return @result
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [migrator].[CopyTable]

@sourceLinkedServer nvarchar(128),
@sourceDatabase nvarchar(128),
@targetDatabase nvarchar(128),
@schema nvarchar(128),
@table nvarchar(128)

as begin

SET NOCOUNT ON

declare @sourceTableName nvarchar(512) = (select migrator.GetTableNameFromParts(@sourceLinkedServer, @sourceDatabase, @schema, @table))
declare @targetTableName nvarchar(512) = (select migrator.GetTableNameFromParts(null, @targetDatabase, @schema, @table))

exec migrator.EnsureTableExists @sourceLinkedServer, @sourceDatabase, @schema, @table
exec migrator.EnsureTableExists null, @targetDatabase, @schema, @table

-- Get table columns as CSV
declare @columnsCsv table ([value] nvarchar(max))
insert into @columnsCsv ([value])
exec migrator.GetTableColumnsAsCsv @sourceLinkedServer, @sourceDatabase, @schema, @table
declare @columns nvarchar(max) = (select [value] from @columnsCsv)

-- Copy data and enable identity insert if needed
declare @insertQuery nvarchar(max)
if (IDENT_CURRENT(@targetTableName) is not null)

	set @insertQuery = 
	'
	if not exists(select * from ' + @targetTableName + ')

	begin

		set identity_insert ' + @targetTableName + ' on

		insert into ' + @targetTableName + '('+@columns+')

		select ' + @columns + ' from ' + @sourceTableName + ' WITH(TABLOCK)

		set identity_insert '+@targetTableName +' off

	end
	'
else
	set @insertQuery = 
	'
	if not exists(select * from ' + @targetTableName +')

	begin

		insert into ' + @targetTableName + '(' + @columns + ')

		select ' + @columns + ' from ' + @sourceTableName + ' WITH(TABLOCK)

	end
	'

exec sp_executesql @insertQuery

end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [migrator].[CopyTables]

@sourceLinkedServer nvarchar(128),
@sourceDatabase nvarchar(128),
@targetDatabase nvarchar(128),
@tables [migrator].[Tables] readonly

as begin

SET NOCOUNT ON

-- Check for schema differences
declare @diff migrator.TableSchemaDifference
insert into @diff 
select * from migrator.CompareSchemaAnyTables(@sourceLinkedServer, @sourceDatabase, null, @targetDatabase, @tables)

 if exists (select top 1 * from @diff)
 begin
	select * from @diff;
	throw 51000, 'Table structure has to be the same in the source and in the target location.', 1;
 end

-- Get ordered dependencies
declare @sql nvarchar(max) = 'use ' + @sourceDatabase + '; exec sp_MSdependencies @flags = 8'
declare @msdependencies as table (ObjectType int, TableName nvarchar(128), [Schema] nvarchar(128), [Sequence] int)
insert into @msdependencies
exec sp_executesql @sql

-- Delete and reseed all tables
declare @schemaName nvarchar(128), @tableName nvarchar(128)
DECLARE mycursor CURSOR
FOR

	select d.[Schema], d.TableName 
	from @msdependencies d
	join @tables t on t.[SchemaName] = d.[Schema] and t.TableName = d.TableName
	order by [Sequence] desc, d.[TableName] desc

OPEN mycursor;

FETCH NEXT FROM mycursor INTO @schemaName, @tableName;

WHILE @@FETCH_STATUS = 0
BEGIN

    exec migrator.DeleteAndReseedTable null, @targetDatabase, @schemaName, @tableName

    FETCH NEXT FROM mycursor INTO @schemaName, @tableName;
END;

CLOSE mycursor;

-- Copy data for all tables
DECLARE mycursor2 CURSOR
FOR

	select d.[Schema], d.TableName 
	from @msdependencies d
	join @tables t on t.[SchemaName] = d.[Schema] and t.TableName = d.TableName
	order by [Sequence], d.[TableName]

OPEN mycursor2;

FETCH NEXT FROM mycursor2 INTO @schemaName, @tableName;

WHILE @@FETCH_STATUS = 0
BEGIN

    exec migrator.CopyTable @sourceLinkedServer, @sourceDatabase, @targetDatabase, @schemaName, @tableName 

    FETCH NEXT FROM mycursor2 INTO @schemaName, @tableName;
END;

CLOSE mycursor2;


end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [migrator].[DeleteAndReseedTable] 
(
	@linkedServer nvarchar(128),
	@database nvarchar(128),
	@schema nvarchar(128),
	@table nvarchar(128)
)
as 
begin

	SET NOCOUNT ON

	if (@table is null or @table = '') throw 51000, 'Parameter @tableName cannot be null or empty.', 1
	declare @object nvarchar(512) = (select migrator.GetTableNameFromParts(@linkedServer, @database, @schema, @table))

	-- Delete table
	declare @deleteQuery nvarchar(519) = 'delete ' + @object
	EXEC sp_executesql @deleteQuery

	-- Reseed table
	--  if it has identity column
	--  if it is not a new table
	if (IDENT_CURRENT(@object) is not null)
	begin
		declare @isNew bit
		exec @isNew = migrator.IsNewTableWithoutHistoricalIdentityValue @linkedServer, @database, @schema, @table
		if (@isNew != 1)
			dbcc checkident (@object, RESEED, 0)
	end

end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [migrator].[EnsureTableExists]
	@linkedServer nvarchar(128),
	@database nvarchar(128),
	@schema nvarchar(128),
	@table nvarchar(128)
as
begin

	declare @prefix nvarchar(256) = (select migrator.GetDatabaseNameFromParts(@linkedServer, @database))

	if (@prefix is null) 
		set @prefix = ''
	else 
		set @prefix = @prefix + '.'

	declare @query nvarchar(max) = '
	SELECT TABLE_NAME
	FROM ' + @prefix + 'INFORMATION_SCHEMA.TABLES 
	WHERE [TABLE_CATALOG] = ''' + @database + ''' and TABLE_SCHEMA = ''' + @schema + ''' and TABLE_NAME= ''' + @table + '''
	'
	
	declare @informationSchema table ([value] nvarchar(max))
	insert into @informationSchema ([value])
	exec sp_executesql @query

	if not exists(select * from @informationSchema)
	begin
		declare @tableName nvarchar(512) = (select migrator.GetTableNameFromParts(@linkedServer, @database, @schema, @table));
		declare @exception nvarchar(max) = 'Table name ' + @tableName + ' does not exist.';
		throw 51000, @exception, 1
	end
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [migrator].[GetTableColumnsAsCsv]
	@linkedServer nvarchar(128),
	@database nvarchar(128),
	@schema nvarchar(128),
	@table nvarchar(128),
	@withComputedColumns bit = 0
as
begin

	declare @sysPrefix nvarchar(256) = (select migrator.GetDatabaseNameFromParts(@linkedServer, @database))

	if (@sysPrefix is null) 
		set @sysPrefix = ''
	else 
		set @sysPrefix = @sysPrefix + '.'

	declare @query nvarchar(max) = ''

	if (@withComputedColumns = 1)
		set @query = '
		SELECT STUFF(
		(
			SELECT '','' + QUOTENAME(COLUMN_NAME) 
			FROM ' + @sysPrefix + 'INFORMATION_SCHEMA.COLUMNS 
			WHERE [TABLE_CATALOG] = ''' + @database + ''' and [TABLE_SCHEMA]= ''' + @schema + ''' and TABLE_NAME= ''' + @table + '''
			FOR XML PATH('''')
		),1,1,'''')'
	else
		set @query = '
		SELECT STUFF(
		(
		SELECT '','' + QUOTENAME(COLUMN_NAME) 
		FROM ' + @sysPrefix + 'INFORMATION_SCHEMA.COLUMNS
	
		outer apply
		(
		SELECT column_id
		FROM ' + @sysPrefix + 'sys.computed_columns
		join ' + @sysPrefix + 'sys.objects on objects.[object_id] = computed_columns.[object_id]
		join ' + @sysPrefix + 'sys.schemas on schemas.[schema_id] = objects.[schema_id]
		where schemas.[name] = COLUMNS.TABLE_SCHEMA 
		and objects.[name] = COLUMNS.TABLE_NAME
		and computed_columns.[name] = COLUMNS.COLUMN_NAME
		) computedColumn

		WHERE [TABLE_CATALOG] = ''' + @database + ''' and [TABLE_SCHEMA]= ''' + @schema + ''' and TABLE_NAME= ''' + @table + '''
		and computedColumn.column_id is null

		FOR XML PATH('''')
		),1,1,'''')'

	exec sp_executesql @query

end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [migrator].[IsNewTableWithoutHistoricalIdentityValue] 
(
	@linkedServer nvarchar(128),
	@database nvarchar(128),
	@schema nvarchar(128),
	@table nvarchar(128)
)
as
begin
	
	declare @object nvarchar(512) = (select migrator.GetTableNameFromParts(null, @database, @schema, @table))
	declare @sysPrefix nvarchar(256) = (select migrator.GetTableNameFromParts(@linkedServer, @database, null, null))

	if (@sysPrefix is null) 
		set @sysPrefix = ''
	else 
		set @sysPrefix = @sysPrefix + '.'

	declare @query nvarchar(max) = 
	'if exists(select * from '+ @sysPrefix + 'sys.identity_columns where [object_id] = OBJECT_ID('''+ @object +''') and last_value is null)
		select @returnValue = cast(1 as bit)
	else
		select @returnValue = cast(0 as bit)'
	
	declare @result bit 
	declare @outputDefinition nvarchar(255) = N'@returnValue bit OUTPUT';
	exec sp_executesql @query, @outputDefinition, @returnValue = @result OUT

	select @result

end
GO
