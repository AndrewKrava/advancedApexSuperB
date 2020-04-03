@isTest (seeAllData=true)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        Pagereference newPageRef = page.Product2New;

        Product2 prod = new Product2(Name = 'New Test Product');
        Product2Extension.ProductWrapper item = new Product2Extension.ProductWrapper();
        item.productRecord.Name = 'Wreapper Test';
        item.productRecord.Family = 'Side';
        item.productRecord.IsActive = true;
        item.pricebookEntryRecord.UnitPrice = 58;
        item.productRecord.Initial_Inventory__c = 14;
        
        Test.startTest();
            Product2Extension ext = new Product2Extension(new Apexpages.StandardController(prod));
            System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size(), '5 rows');
            ext.addRows();
            System.assertEquals(2*Constants.DEFAULT_ROWS , ext.productsToInsert.size(), '2*5 rows');

            List<Product2Extension.ProductWrapper> wrapper = ext.productsToInsert;
            wrapper.add(item);

            List<SelectOption> familyOptions = ext.getFamilyOptions();
            List<ChartHelper.ChartData> chartDate = ext.getInventory();
            PageReference pageRef =  ext.save();
        Test.stopTest();

        Product2 result = [
                                SELECT Name
                                FROM Product2
                                WHERE Name = 'Wreapper Test'
                                LIMIT 1
                                ];  

        System.assertEquals('Wreapper Test', result.Name, '\"Wreapper Test\" expected name');
        System.assertEquals(null, pageRef, 'Expected null');
        System.assertEquals(4, chartDate.size(), 'Expected 4 elements of chart!');
        System.assertEquals(5, familyOptions.size(), 'Expected 5 elements!');
        System.assertEquals('Select one', familyOptions[0].getLabel(), '\"Select one\" expected first label in Family pick list!');
    }

}