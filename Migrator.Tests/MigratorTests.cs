using Migrator.Tests.Utils;
using System.Linq;
using Xunit;

namespace Migrator.Tests
{
    public class MigratorTests
    {
        [Fact]
        public void Copy_Tables_Without_Linked_Server()
        {
            // Arrange
            var configuration = new TestConfiguration();
            using var migrator = new MigratorDatabase(configuration);
            using var source = new SourceDatabase(configuration);
            using var target = new TargetDatabase(configuration);

            migrator.Initialize(seed: true);
            source.Initialize(seed: true);
            target.Initialize();

            // Act
            migrator.CopyTablesWithoutLinkedServer();

            // Assert
            var context = target.GetContext();
            Assert.True(condition: context.Addresses.Any());
            Assert.True(condition: context.Customers.Any());
            Assert.True(condition: context.Orders.Any());
            Assert.True(condition: context.OrderLines.Any());
            Assert.True(condition: context.Products.Any());
        }

        [Fact]
        public void Copy_Tables_With_Linked_Server()
        {
            // Arrange
            var configuration = new TestConfiguration();
            using var migrator = new MigratorDatabase(configuration);
            using var source = new SourceDatabase(configuration);
            using var target = new TargetDatabase(configuration);

            source.Initialize(seed: true);
            migrator.Initialize(seed: true);
            target.Initialize();
            target.RegisterLinkedServer();

            // Act
            migrator.CopyTablesWithLinkedServer();

            // Assert
            var context = target.GetContext();
            Assert.True(condition: context.Addresses.Any());
            Assert.True(condition: context.Customers.Any());
            Assert.True(condition: context.Orders.Any());
            Assert.True(condition: context.OrderLines.Any());
            Assert.True(condition: context.Products.Any());
        }
    }
}