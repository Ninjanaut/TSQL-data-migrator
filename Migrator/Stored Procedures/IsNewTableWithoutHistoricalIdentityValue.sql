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