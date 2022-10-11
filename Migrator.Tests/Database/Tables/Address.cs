namespace Migrator.Tests.Database.Tables
{
    internal class Address
    {
        public int CustomerId { get; private set; }
        public string City { get; private set; }
        public string Street { get; private set; }
        public string PostalCode { get; private set; }

        // Navigation property
        public Customer Customer { get; private set; }

        // EF constructor
        private Address() { }
        
        public Address(string city, string street, string postalCode)
        {
            City = city;
            Street = street;
            PostalCode = postalCode;
        }
    }
}
