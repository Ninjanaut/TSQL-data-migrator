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