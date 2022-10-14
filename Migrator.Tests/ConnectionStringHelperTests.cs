using Migrator.Tests.Utils;
using Xunit;

namespace Migrator.Tests
{
    public class ConnectionStringHelperTests
    {
        [Theory]
        // Database
        [InlineData("Data Source = localhost;Database=DatabaseName;", "DatabaseName")]
        [InlineData("Data Source = localhost;Database= DatabaseName;", "DatabaseName")]
        [InlineData("Data Source = localhost;Database =DatabaseName", "DatabaseName")]
        [InlineData("Data Source = localhost;Database = DatabaseName", "DatabaseName")]
        [InlineData("Data Source = localhost;Database =DatabaseName ", "DatabaseName")]
        [InlineData("Data Source = localhost; Database =DatabaseName ", "DatabaseName")]
        [InlineData("Data Source = localhost; Database = DatabaseName;", "DatabaseName")]
        [InlineData("Database = DatabaseName; Data Source = localhost", "DatabaseName")]
        [InlineData("User ID=sa; Database = DatabaseName; Data Source = localhost", "DatabaseName")]
        [InlineData("User ID=sa;Database = DatabaseName; Data Source = localhost", "DatabaseName")]
        [InlineData("User ID=sa;Database  = DatabaseName; Data Source = localhost", "DatabaseName")]
        [InlineData("User ID=sa;dAtAbAsE  = DatabaseName; Data Source = localhost", "DatabaseName")]
        // Initial Catalog
        [InlineData("Data Source = localhost;Initial Catalog=DatabaseName;", "DatabaseName")]
        [InlineData("Data Source = localhost;Initial Catalog= DatabaseName;", "DatabaseName")]
        [InlineData("Data Source = localhost;Initial Catalog =DatabaseName", "DatabaseName")]
        [InlineData("Data Source = localhost;Initial Catalog = DatabaseName", "DatabaseName")]
        [InlineData("Data Source = localhost;Initial Catalog =DatabaseName ", "DatabaseName")]
        [InlineData("Data Source = localhost; Initial Catalog =DatabaseName ", "DatabaseName")]
        [InlineData("Data Source = localhost; Initial Catalog = DatabaseName;", "DatabaseName")]
        [InlineData("Initial Catalog = DatabaseName; Data Source = localhost", "DatabaseName")]
        [InlineData("User ID=sa; Initial Catalog = DatabaseName; Data Source = localhost", "DatabaseName")]
        [InlineData("User ID=sa;Initial Catalog = DatabaseName; Data Source = localhost", "DatabaseName")]
        [InlineData("User ID=sa;Initial Catalog  = DatabaseName; Data Source = localhost", "DatabaseName")]
        [InlineData("User ID=sa;iNiTiAl CaTaLoG  = DatabaseName; Data Source = localhost", "DatabaseName")]
        public void GetDatabase(string connectionString, string databaseName)
        {
            // Act
            var output = ConnectionStringHelper.GetDatabase(connectionString);
            // Assert
            Assert.Equal(databaseName, output);            
        }

        [Theory]
        // Data Source
        [InlineData("Data Source=localhost;Database = DatabaseName;", "localhost")]
        [InlineData("Data Source =localhost;Database = DatabaseName;", "localhost")]
        [InlineData("Data Source= localhost;Database = DatabaseName;", "localhost")]
        [InlineData("Data Source = localhost;Database = DatabaseName;", "localhost")]
        [InlineData("Data Source  =  localhost;Database = DatabaseName;", "localhost")]
        [InlineData("Database = DatabaseName;Data Source = localhost;", "localhost")]
        [InlineData("Database = DatabaseName; Data Source = localhost;", "localhost")]
        [InlineData("Database = DatabaseName; dAtA sOuRcE = localhost;", "localhost")]
        // Server
        [InlineData("Server=localhost;Database = DatabaseName;", "localhost")]
        [InlineData("Server =localhost;Database = DatabaseName;", "localhost")]
        [InlineData("Server= localhost;Database = DatabaseName;", "localhost")]
        [InlineData("Server = localhost;Database = DatabaseName;", "localhost")]
        [InlineData("Server  =  localhost;Database = DatabaseName;", "localhost")]
        [InlineData("Database = DatabaseName;Server = localhost;", "localhost")]
        [InlineData("Database = DatabaseName; Server = localhost;", "localhost")]
        [InlineData("Database = DatabaseName; sErVer = localhost;", "localhost")]
        public void GetDataSource(string connectionString, string dataSource)
        {
            // Act
            var output = ConnectionStringHelper.GetDataSource(connectionString);
            // Assert
            Assert.Equal(dataSource, output);
        }

        [Theory]
        [InlineData("Data Source = localhost; Database = DatabaseName;", "localhost")]
        [InlineData("Data Source = localhost,123; Database = DatabaseName;", "localhost")]
        public void GetLinkedServer(string connectionString, string linkedServer)
        {
            // Act
            var output = ConnectionStringHelper.GetLinkedServer(connectionString);
            // Assert
            Assert.Equal(linkedServer, output);
        }
    }
}
