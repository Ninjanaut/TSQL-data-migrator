using Microsoft.EntityFrameworkCore;
using Migrator.Tests.Configuration;
using Migrator.Tests.Database;
using System;
using System.IO;

namespace Migrator.Tests.Utils
{
    internal class MigratorDatabase : IDisposable
    {
        private readonly MigratorDatabaseContext _context;
        private readonly DatabaseConnectionStrings _connectionStrings;
        public MigratorDatabase(TestConfiguration configurationHelper)
        {
            _connectionStrings = configurationHelper.GetConnectionStrings();

            _context = 
                new MigratorDatabaseContext(
                    new DbContextOptionsBuilder<MigratorDatabaseContext>()
                        .UseSqlServer(_connectionStrings.Migrator).Options);
        }

        public void Initialize(bool seed)
        {
            _context.Database.EnsureDeleted();
            _context.Database.EnsureCreated();
            if (seed) Seed();
        }

        private void Seed()
        {
            var path = Path.GetFullPath(@"..\..\..\..\Migrator\bin\Debug\Scripts\migrator-installation.sql");

            if (!File.Exists(path)) 
                throw new Exception("The migrator-installation.sql was not found, please try to build Migrator project first (in debug mode).");

            var sql = File.ReadAllText(path);
            string[] commands = sql.Split(new string[] { "GO" }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var command in commands)
            {
                _context.Database.ExecuteSqlRaw(command);
            }
        }

        public void CopyTablesWithoutLinkedServer()
        {
            var path = Path.GetFullPath(@"TestQueries\migrate-tables-without-linked-server.sql");
            var sql = File.ReadAllText(path);

            var sourceDatabase = ConnectionStringHelper.GetDatabase(_connectionStrings.Source);
            var targetDatabase = ConnectionStringHelper.GetDatabase(_connectionStrings.Target);

            sql = sql.Replace("<SourceDatabase>", sourceDatabase);
            sql = sql.Replace("<TargetDatabase>", targetDatabase);

            _context.Database.ExecuteSqlRaw(sql);
        }

        public void CopyTablesWithLinkedServer()
        {
            var path = Path.GetFullPath(@"TestQueries\migrate-tables-with-linked-server.sql");
            var sql = File.ReadAllText(path);

            var linkedServer = ConnectionStringHelper.GetLinkedServer(_connectionStrings.Source);
            var sourceDatabase = ConnectionStringHelper.GetDatabase(_connectionStrings.Source);
            var targetDatabase = ConnectionStringHelper.GetDatabase(_connectionStrings.Target);

            sql = sql.Replace("<LinkedServer>", linkedServer);
            sql = sql.Replace("<SourceDatabase>", sourceDatabase);
            sql = sql.Replace("<TargetDatabase>", targetDatabase);

            _context.Database.ExecuteSqlRaw(sql);
        }

        public void Dispose()
        {
            if (_context != null) _context.Dispose();
        }
    }
}
