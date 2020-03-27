@isTest
private class test_agregationSOQL {


    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'Food');
        insert acc;
        
        Product2 prod1 = new Product2(Name = 'Pizza',
                                    IsActive =true,
                                    Initial_Inventory__c = 10
                                    );
        Product2 prod2 = new Product2(Name = 'Whater',
                                        IsActive =true,
                                        Initial_Inventory__c = 20	
                                        );
        insert new List<Product2> {prod2, prod1};


        Order order1 = new Order(AccountId = acc.Id,
                                Status = Constants.DRAFT_ORDER_STATUS,
                                Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
                                EffectiveDate = Date.today()
                                );
        Order order2 = new Order(AccountId = acc.Id,
                                Status = Constants.DRAFT_ORDER_STATUS,
                                Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
                                EffectiveDate = Date.today()
                                );
        insert new List<Order> {order1, order2};
        
        PricebookEntry priceItem_1= new PricebookEntry(Product2Id = prod1.Id,
                                                    Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
                                                    IsActive = true,
                                                    UnitPrice = 100
                                                    //UseStandardPrice = true
                                                    );
        PricebookEntry priceItem_2 = new PricebookEntry(Product2Id = prod2.Id,
                                                    Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
                                                    IsActive = true,
                                                    UnitPrice = 100
                                                    //UseStandardPrice = true
                                                    );
        insert new List<PricebookEntry> {priceItem_1, priceItem_2};

        OrderItem orderItem_Pizza_1 = new OrderItem(OrderId = order1.Id,
                                            Product2Id = prod1.Id,
                                            PricebookEntryId = priceItem_1.Id,
                                            Quantity = 2,
                                            UnitPrice = 100
                                            );
        OrderItem orderItem_Whater_1 = new OrderItem(OrderId = order1.Id,
                                            Product2Id = prod2.Id,
                                            PricebookEntryId = priceItem_2.Id,
                                            Quantity = 5,
                                            UnitPrice = 100
                                            );
        OrderItem orderItem_Pizza_2 = new OrderItem(OrderId = order2.Id,
                                            Product2Id = prod1.Id,
                                            PricebookEntryId = priceItem_1.Id,
                                            Quantity = 4,
                                            UnitPrice = 100
                                            );
        OrderItem orderItem_Whater_2 = new OrderItem(OrderId = order2.Id,
                                            Product2Id = prod2.Id,
                                            PricebookEntryId = priceItem_2.Id,
                                            Quantity = 7,
                                            UnitPrice = 100
                                            );
        insert new List<OrderItem> {orderItem_Pizza_1, orderItem_Pizza_2, orderItem_Whater_1, orderItem_Whater_2};
    }


    @isTest
    private static void test_method_agregationSOQL() {

        List<Order> update_orders = new List<Order>();
        List<Order> before_update_Orders = [
                                            SELECT Status
                                            FROM Order                
                                            ];
        for (Order o : before_update_Orders) {
            o.Status = Constants.ACTIVATED_ORDER_STATUS;
            update_orders.add(o);
        }
        

        Test.startTest();
            update update_orders;
        Test.stopTest();

     
        
        List<Product2> check_pizza = new List<Product2>();
        List<Product2> check_whater = new List<Product2>();
        List<Product2> list_check = [
                                        SELECT Name, Initial_Inventory__c, Quantity_Ordered__c, Quantity_Remaining__c
                                        FROM Product2
                                    ];
        for (Product2 prod : list_check) {
            if (prod.Name == 'Pizza') {
                check_pizza.add(prod);
            } else if (prod.Name == 'Whater') {
                check_whater.add(prod);
            } else {
                System.debug('Something gone wrong!!!');
            }
        }

        System.assertEquals(6, check_pizza[0].Quantity_Ordered__c, 'Expected 6 ordered pizza');
        System.assertEquals(4, check_pizza[0].Quantity_Remaining__c, 'Expected 4 pizza remaning');
        System.assertEquals(12, check_whater[0].Quantity_Ordered__c, 'Expected 12 whater ordered');
        System.assertEquals(8, check_whater[0].Quantity_Remaining__c, 'Expected 8 whater remaining');

    }

    // @isTest
    // private static void failTestOrderTrigger() {
    // List<Order> failOrders = [
    //                                         SELECT Id
    //                                         FROM Order                
    //                                         ];
    // Set<Id> failIds = new Set<Id>();
    // for (Order o : failOrders) {
    //     failIds.add(o.Id);
    // }

    // List<Boolean> listExceptions = new List<Boolean>();
    // Test.startTest();
    // try {
    //     OrderHelper.rollUpOrderItems(failIds);
    // } catch (DmlException ex) {
    //     if (!String.isEmpty(ex.getMessage())){
    //         listExceptions.add(true);
    //     }
    // }
    // Test.stopTest();
    // System.assert(listExceptions[0], 'Expect throw exception');

    // }

}
