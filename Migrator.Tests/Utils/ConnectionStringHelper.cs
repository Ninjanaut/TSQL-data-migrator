using System;
using System.Text.RegularExpressions;

namespace Migrator.Tests.Utils
{
    internal static class ConnectionStringHelper
    {
        /// <param name="connectionString">SQL Server connection string</param>
        /// <exception cref="ArgumentException"></exception>
        internal static string GetDatabase(string connectionString)
        {

            Regex rx = new("(Database=|Database( *)=|Initial Catalog=|Initial Catalog( *)=)([^;]*)", 
                RegexOptions.Compiled | RegexOptions.IgnoreCase);

            string result = rx.Match(connectionString).ToString();

            result = RemoveEquationLeftSide(result);

            if (!string.IsNullOrEmpty(result)) return result.Trim();

            throw new ArgumentException("Database not found in connection string.", nameof(connectionString));
        }

        /// <param name="connectionString">SQL Server connection string</param>
        /// <exception cref="ArgumentException"></exception>
        internal static string GetDataSource(string connectionString)
        {
            Regex rx = new("(Server=|Server( *)=|Data Source=|Data Source( *)=)([^;]*)",
                RegexOptions.Compiled | RegexOptions.IgnoreCase);

            string result = rx.Match(connectionString).ToString();

            result = RemoveEquationLeftSide(result);

            if (!string.IsNullOrEmpty(result)) return result.Trim();

            throw new ArgumentException("Database not found in connection string.", nameof(connectionString));
        }

        private static string RemoveEquationLeftSide(string text)
        {
            return text.Substring(text.IndexOf("=") + 1);
        }

        internal static string GetLinkedServer(string connectionString)
        {
            var dataSource = GetDataSource(connectionString);
            return dataSource.Substring(0, dataSource.IndexOf(','));
        }
    }
}
