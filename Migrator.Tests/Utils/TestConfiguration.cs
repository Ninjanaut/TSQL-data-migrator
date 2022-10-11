using Microsoft.Extensions.Configuration;
using Migrator.Tests.Configuration;

namespace Migrator.Tests.Utils
{
    internal class TestConfiguration
    {
        private readonly IConfigurationRoot _configuration;
        public TestConfiguration()
        {
            _configuration = new ConfigurationBuilder()
                .AddJsonFile("appsettings.json", optional: false)
                .Build();
        }
        public DatabaseConnectionStrings GetConnectionStrings()
        {
            DatabaseConnectionStrings connectionStrings = new();
            _configuration.GetSection("DatabaseConnectionStrings").Bind(connectionStrings);
            connectionStrings.Validate();
            return connectionStrings;
        }
    }
}
