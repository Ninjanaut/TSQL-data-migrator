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