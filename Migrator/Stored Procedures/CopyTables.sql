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