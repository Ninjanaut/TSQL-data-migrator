using System;
using System.Collections.Generic;

namespace Migrator.Tests.Database.Tables
{
    internal class Order
    {
        public int Id { get; private set; }
        public int CustomerId { get; private set; }
        public string Status { get; private set; }
        public DateTime OrderDate { get; private set; }

        // Navigation property
        public List<OrderLine> Lines { get; private set; } = new List<OrderLine>();

        // EF constructor
        private Order() { }

        public Order(Customer customer)
        {
            CustomerId = customer.Id;
            Status = "Ordered";
        }

        public void AddItem(OrderLine item)
        {
            Lines.Add(item);
        }
    }
}
