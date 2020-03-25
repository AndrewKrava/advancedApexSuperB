@isTest
private class OrderItem_Test {
    
    @isTest
    private static void getOrderItemTest() {

        Id pricebookId = Test.getStandardPricebookId();

        Account acc = new Account(Name = 'Food');
        insert acc;
        
        Product2 prod = new Product2(Name = 'Pizza',
                                    IsActive =true
                                    );
        insert prod;
        
        Order order = new Order(AccountId = acc.Id,
                                Status = 'Draft',
                                Pricebook2Id = pricebookId,
                                EffectiveDate = Date.today()
                                );

        insert order;

        // Pricebook2 pricebook = new Pricebook2(Name = 'price for pizza?');
        // insert pricebook;
        
        
        PricebookEntry priceItem = new PricebookEntry(Product2Id = prod.Id,
                                                    Pricebook2Id = pricebookId,
                                                    IsActive = true,
                                                    UnitPrice = 100
                                                    //UseStandardPrice = true
                                                    );
        insert priceItem;

        OrderItem orderItem = new OrderItem(OrderId = order.Id,
                                            Product2Id = prod.Id,
                                            PricebookEntryId = priceItem.Id,
                                            
                                            Quantity = 10,
                                            UnitPrice = 100
                                            );
        insert orderItem;

        List<OrderItem> resultOI = [
            SELECT OrderId, Product2Id, Quantity, AvailableQuantity
            FROM OrderItem
            ];
        List<Order> resultOrder = [
            SELECT Status
            FROM Order
            ];
        List<Product2> resultProd = [
            SELECT Name
            FROM Product2
            ];

        System.assertEquals(10, resultOI[0].Quantity, 'quantity 10');
    }
}
