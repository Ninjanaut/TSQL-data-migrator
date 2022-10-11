using Microsoft.EntityFrameworkCore;
using Migrator.Tests.Database;
using Migrator.Tests.Database.Tables;
using System;

namespace Migrator.Tests.Utils
{
    internal class SourceDatabase : IDisposable
    {
        private readonly TestDatabaseContext _context;

        public SourceDatabase(TestConfiguration configurationHelper)
        {
            var connectionStrings = configurationHelper.GetConnectionStrings();

            _context = 
                new TestDatabaseContext(
                    new DbContextOptionsBuilder<TestDatabaseContext>()
                        .UseSqlServer(connectionStrings.Source).Options);
        }

        public void Initialize(bool seed)
        {
            _context.Database.EnsureDeleted();
            _context.Database.EnsureCreated();
            if (seed) Seed();
        }

        private void Seed()
        {
            // Create customers with address
            var customer1 =
                new Customer("Patricia", "Warren",
                    new Address("Oakland", "1668 Wolf Pen Road", "94612"));

            var customer2 =
                new Customer("Mary", "Wilkins",
                    new Address("Cedar Hill", "4349 Irving Place", "63016"));

            var customer3 =
                new Customer("David", "Hickman",
                    new Address("Springfield", "2234 Kinney Street", "01103"));

            var customer4 =
                new Customer("Gary", "Jarvis",
                    new Address("Wilmette", "2077 Pinewood Drive", "60091"));

            // create Products
            var product1 = new Product("1234567890", "iPhone 14");
            var product2 = new Product("2345678901", "Samsung galaxy S22");
            var product3 = new Product("3456789012", "Huawei P50");
            var product4 = new Product("4567890123", "BlackBerry Evolve");

            // Save customers and products to database
            _context.Customers.Add(customer1);
            _context.Customers.Add(customer2);
            _context.Customers.Add(customer3);
            _context.Customers.Add(customer4);

            _context.Products.Add(product1);
            _context.Products.Add(product2);
            _context.Products.Add(product3);
            _context.Products.Add(product4);

            _context.SaveChanges();

            // Create orders
            var order1 = new Order(customer1);
            order1.AddItem(new OrderLine(product1, 1, 12));
            order1.AddItem(new OrderLine(product2, 2, 13));

            var order2 = new Order(customer2);
            order2.AddItem(new OrderLine(product1, 1, 14));

            var order3 = new Order(customer2);
            order3.AddItem(new OrderLine(product3, 2, 15));

            var order4 = new Order(customer4);
            order4.AddItem(new OrderLine(product4, 1, 16));

            // Save orders to database
            _context.Orders.Add(order1);
            _context.Orders.Add(order2);
            _context.Orders.Add(order3);
            _context.Orders.Add(order4);

            _context.SaveChanges();
        }

        public void Dispose()
        {
            if(_context != null) _context.Dispose();
        }
    }
}
