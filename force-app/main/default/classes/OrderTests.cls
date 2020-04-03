@isTest (seeAllData=false)
private class OrderTests {
    @TestSetup
    static void setupTestData(){
        TestDataFactory.insertTestData(10);
    }

    @isTest
    private static void testProdcutUpdate() {
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

}