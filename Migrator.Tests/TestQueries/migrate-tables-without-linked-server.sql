declare @tables as migrator.[Tables] ;

insert into @tables (SchemaName, TableName) values
('dbo', 'Address'), 
('dbo', 'Customer'), 
('dbo', 'Order'), 
('dbo', 'OrderLine'), 
('dbo', 'Product')

exec migrator.[CopyTables]
@sourceLinkedServer = null,
@sourceDatabase  = '<SourceDatabase>',
@targetDatabase = '<TargetDatabase>',
@tables = @tables