if exists(select * from sys.servers where name = N'<LinkedServer>')
	exec sp_dropserver '<LinkedServer>';

exec master.dbo.sp_addlinkedserver @server = N'<LinkedServer>', @srvproduct=N'SQL Server';  
