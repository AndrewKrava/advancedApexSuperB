public class Product2Extension {

    private final Product2 prod;
    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(Apexpages.StandardController stdController){
        this.prod = (Product2) stdController.getRecord();
        productsToInsert = new List<ProductWrapper>();
        addRows();
        ChartHelper.GetInventory();
    }

    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }

    }

    public List<SelectOption> getFamilyOptions() {
        List<SelectOption> familyOptions = new List<SelectOption>();
        familyOptions.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for (Schema.PicklistEntry o : Constants.PRODUCT_FAMILY) {
            familyOptions.add(new SelectOption(o.getValue(), o.getLabel()));
        }
        return familyOptions;
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){

        Savepoint sp = Database.setSavepoint();
        List<Product2> pToInsert = new List<Product2>();
        List<PricebookEntry> prEntryToInsert = new List<PricebookEntry>();
        try {

            for (ProductWrapper item : productsToInsert) {
                if (String.isNotBlank(item.productRecord.Name) && !String.isEmpty(item.productRecord.Name) &&
                    item.productRecord.Family != null && item.productRecord.Family != Constants.SELECT_ONE &&
                    item.productRecord.Initial_Inventory__c != null && item.productRecord.Initial_Inventory__c != 0 &&
                    item.pricebookEntryRecord.UnitPrice != null && item.pricebookEntryRecord.UnitPrice != 0) {
                        pToInsert.add(item.productRecord);
                }
            }
            Database.insert(pToInsert, false);
            for (ProductWrapper item : productsToInsert) {
                if (item.productRecord.Id != null) {
                    PricebookEntry newPrEntry = new PricebookEntry (
                                                                    Product2Id = item.productRecord.Id,
                                                                    Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
                                                                    IsActive = true,
                                                                    UnitPrice = item.pricebookEntryRecord.UnitPrice                                            
                                                                );
                    prEntryToInsert.add(newPrEntry);
                }
            }
            Database.insert(prEntryToInsert,false);

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,pToInsert.size()+' Inserted. Only products that have all fields populated was saved!'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (DmlException e){
            If (sp != null) {
                Database.rollback(sp);
                apexPages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Constants.ERROR_MESSAGE));
                throw new DmlException(e.getMessage());
            }
        }
         return null;
    }
    private class ProductWrapper {
        public Product2 productRecord {get;set;}
        public PricebookEntry pricebookEntryRecord {get;set;}
        private ProductWrapper() {
            productRecord = new Product2();
            pricebookEntryRecord = new PricebookEntry();
        }
    }
}