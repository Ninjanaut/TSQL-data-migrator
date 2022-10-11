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