using System;

namespace Migrator.Tests.Configuration
{
    internal class DatabaseConnectionStrings
    {
        public string Source { get; set; }
        public string Target{ get; set; }
        public string Migrator { get; set; }

        public void Validate()
        {
            if (string.IsNullOrEmpty(Source)) 
                throw new ArgumentException("Argument is mandatory.", nameof(Source));

            if (string.IsNullOrEmpty(Target)) 
                throw new ArgumentException("Argument is mandatory.", nameof(Target));

            if (string.IsNullOrEmpty(Migrator)) 
                throw new ArgumentException("Argument is mandatory.", nameof(Migrator));
        }
    }
}
