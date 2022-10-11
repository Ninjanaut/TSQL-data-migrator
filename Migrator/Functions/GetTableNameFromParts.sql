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