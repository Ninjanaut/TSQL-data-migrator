using System;

namespace Migrator.Tests.Database.Tables
{
    internal class OrderLine
    {
        public int OrderId { get; private set; }
        public int ProductId { get; private set; }
        public int Quantity { get; private set; }
        public decimal UnitPrice { get; private set; }

        // Navigation property
        public Product Product { get; private set; }

        // EF constructor
        private OrderLine() { }

        public OrderLine(Product product, int quantity, decimal unitPrice)
        {
            ProductId = product.Id;
            Quantity = quantity;
            UnitPrice = unitPrice;
        }
    }
}
