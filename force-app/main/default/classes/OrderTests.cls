@isTest (seeAllData=false)
private class OrderTests {
    @TestSetup
    static void setupTestData(){
        TestDataFactory.insertTestData(10);
    }

    @isTest
    private static void orderUpdate_UnitTest() {
    	Order selectedOrder = [
                                SELECT name,Status, Id 
                                FROM Order 
                                LIMIT 1
                                ];
        Product2 oldProd = [
                            SELECT Quantity_Ordered__c, Name, Id 
                            FROM Product2 
                            LIMIT 1
                            ];
        
        selectedOrder.Status = Constants.ACTIVATED_ORDER_STATUS;
        update selectedOrder;
        
        Product2 updatedProd = [
                                SELECT Quantity_Ordered__c, Name, Id 
                                FROM Product2 
                                LIMIT 1
                                ];
        
        TestDataFactory.VerifyQuantityOrdered(oldProd,updatedProd,Constants.DEFAULT_ROWS);    
    }


    @isTest
    private static void orderTriggerTest() {
        Pagereference pageRef = page.Product2New;
        Test.setCurrentPageReference(pageRef);

        
        List<Product2> originProducts = [
                                        SELECT Name, Quantity_Ordered__c
                                        FROM Product2
                                        WHERE Name LIKE 'Test Product%'
                                    ];
        Product2 oldProd = [Select Quantity_Ordered__c, Name, Id from Product2 limit 1];
        List<Order> ordersToUpdate = new List<Order>();
        for (Order o : [
                        SELECT Name, Status
                        FROM Order
                        WHERE Name LIKE 'Test Order%'
                    ]) {
            o.Status = Constants.ACTIVATED_ORDER_STATUS;
            ordersToUpdate.add(o);
        }
        Test.startTest();
            update ordersToUpdate;
        Test.stopTest();

        Product2 updatedProd = [Select Quantity_Ordered__c, Name, Id from Product2 limit 1];
        List<Product2> newProducts = [
                                        SELECT Name, Quantity_Ordered__c
                                        FROM Product2
                                        WHERE Name LIKE 'Test Product%'
                                    ];
        
        TestDataFactory.verifyQuantityOrderedGood(originProducts, newProducts, Constants.DEFAULT_ROWS);
        System.assertEquals(Constants.DEFAULT_ROWS, newProducts[0].Quantity_Ordered__c, 'Expected 5 items was order!');
    }

    @isTest
    private static void orderExtension_UnitTest() {
        Account acc = [
                        SELECT Id
                        FROM Account
                        WHERE Name = 'Account Test 1'
                        LIMIT 1
                        ];
        Order orderCont = new Order(
                                    AccountId = acc.Id,
                                    EffectiveDate = Date.today(),
                                    Name = 'Test Order',
                                    Status = Constants.DRAFT_ORDER_STATUS
                                );
        Order editOrder = [
                            SELECT Id, Name, EffectiveDate, Status, AccountId, Pricebook2Id,
                            (
                                SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, PricebookEntry.Product2Id,
                                        PricebookEntry.Product2.Name, PricebookEntry.Product2.Family, 
                                        PricebookEntry.Product2.Quantity_Remaining__c
                                FROM OrderItems
                            )
                            FROM Order
                            WHERE Name LIKE 'Test Order%'
                            LIMIT 1
                        ];

        Test.startTest();
            OrderExtension newOrderExt = new OrderExtension(new Apexpages.StandardController(orderCont));
            OrderExtension editOrderExt = new OrderExtension(new Apexpages.StandardController(editOrder));
            List<OrderItem> editInitOrderItem = editOrderExt.orderRecord.OrderItems;
            List<SelectOption> selectOptEditPage = editOrderExt.getFamilyOptions();
            editOrderExt.selectedFamily = 'Side';
            editOrderExt.selectFamily();

            Boolean hasNextPage = newOrderExt.getHasNext();
            Boolean hasPreviousPage = newOrderExt.getHasPrevious();
            Integer totalPages = newOrderExt.getTotalPages();
            newOrderExt.next();
            newOrderExt.previous();
            newOrderExt.last();
            newOrderExt.first();
            newOrderExt.save();
            newOrderExt.getPageNumber();
            
        Test.stopTest();

        List<OrderItem> editOrderItem = [

                        SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, PricebookEntry.Product2Id,
                                PricebookEntry.Product2.Name, PricebookEntry.Product2.Family, 
                                PricebookEntry.Product2.Quantity_Remaining__c
                        FROM OrderItem
                        WHERE OrderId = :editOrder.Id
                        ];
        Id pbeSediId = [
                        SELECT Id
                        FROM PricebookEntry
                        WHERE Product2.Family = 'Side'
                        LIMIT 1
                         ].Id;

        System.assertEquals(editOrderItem.size(), editInitOrderItem.size(), 'expected one order item in edit page');
        System.assert(!selectOptEditPage.isEmpty(), 'Slect Option must not be empty');
        System.assertEquals(selectOptEditPage.get(0).getValue(), Constants.SELECT_ONE, 'First option must be SELECT ONE');
        System.assert(selectOptEditPage.contains(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE)), 'Select optioncontains SELECT ONE');
        System.assert(selectOptEditPage.contains(new SelectOption('Side', 'Side')), 'Select option contains SIDE');

        System.assertEquals(true, hasNextPage , 'Expected true for has next page');
        System.assertEquals(false, hasPreviousPage , 'Expected false for has previous page');

        System.assertEquals(2, totalPages, 'expected 3 pages which was create via Data Factory');
        System.assertEquals(pbeSediId, editOrderExt.orderItemList[0].PricebookEntryId, 'Must be the same Id');

        for (OrderItem oi : editOrderExt.orderItemMap.values()) {
            oi.Quantity = 0;
        }

        editOrderExt.save();
        
        for (OrderItem oi : newOrderExt.orderItemList) {
            oi.Quantity = 3;
        }
        newOrderExt.save();

        System.assert(!newOrderExt.orderItemMap.isEmpty());
    }

}