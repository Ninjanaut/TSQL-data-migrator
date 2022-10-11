using Microsoft.EntityFrameworkCore;

namespace Migrator.Tests.Database
{
    internal class MigratorDatabaseContext : DbContext
    {
        public MigratorDatabaseContext(DbContextOptions<MigratorDatabaseContext> options) : base(options) { }
    }
}
