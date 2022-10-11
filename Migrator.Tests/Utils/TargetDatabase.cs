using Microsoft.EntityFrameworkCore;
using Migrator.Tests.Configuration;
using Migrator.Tests.Database;
using System;
using System.IO;

namespace Migrator.Tests.Utils
{
    internal class TargetDatabase : IDisposable
    {
        private readonly TestDatabaseContext _context;
        private readonly DatabaseConnectionStrings _connectionStrings;
        public TestDatabaseContext GetContext()
        {
            return _context;
        }

        public TargetDatabase(TestConfiguration configurationHelper)
        {
            _connectionStrings = configurationHelper.GetConnectionStrings();

            _context = 
                new TestDatabaseContext(
                    new DbContextOptionsBuilder<TestDatabaseContext>()
                        .UseSqlServer(_connectionStrings.Target).Options);
        }

        public void Initialize()
        {
            _context.Database.EnsureDeleted();
            _context.Database.EnsureCreated();
        }

        /// <summary>
        /// Linked server should target source server.
        /// </summary>
        public void RegisterLinkedServer()
        {
            var path = Path.GetFullPath(@"TestQueries\add-linked-server.sql");
            var sql = File.ReadAllText(path);
            var linkedServer = ConnectionStringHelper.GetLinkedServer(_connectionStrings.Source);
            sql = sql.Replace("<LinkedServer>", linkedServer);
            _context.Database.ExecuteSqlRaw(sql);
        }

        public void Dispose()
        {
            if (_context != null) _context.Dispose();
        }
    }
}
