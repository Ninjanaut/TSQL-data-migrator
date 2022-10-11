namespace Migrator.Tests.Database.Tables
{
    internal class Product
    {
        public int Id { get; private set; }
        public string Number { get; private set; }
        public string Name { get; private set; }

        // EF constructor
        private Product() { }

        public Product(string number, string name)
        {
            Number = number;
            Name = name;
        }
    }
}
