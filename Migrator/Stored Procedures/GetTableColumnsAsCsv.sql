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