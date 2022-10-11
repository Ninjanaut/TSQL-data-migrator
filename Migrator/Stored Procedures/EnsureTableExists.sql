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