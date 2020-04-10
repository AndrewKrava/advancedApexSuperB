/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}
    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController; 

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        
        
        
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        
        populateOrderItemMap();
        loadPricebookEntry();
    }

    //method to populate existing order list to Map oi
    
    //method to 
    

    private void loadPricebookEntry() {
        String query = 'SELECT Id, UnitPrice, Product2Id, Product2.Name, Product2.Quantity_Remaining__c, Product2.Family ' +
                        'FROM PricebookEntry ' +
                        'WHERE IsActive = true ';
        if (selectedFamily != null && selectedFamily != Constants.SELECT_ONE) {
            query += ' AND  Product2.Family = \''+selectedFamily + '\'';
        } 
        standardSetController = new Apexpages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
        loadOrderItemData();
    }
    
    private void loadOrderItemData() {
        orderItemList = new List<OrderItem>();
        if (standardSetController != null && standardSetController.getRecords().size() > 0) {
            for (PricebookEntry pre : (List<PricebookEntry>) standardSetController.getRecords()) {
                if (orderItemMap.containsKey(pre.Id)) {
                    orderItemList.add(orderItemMap.get(pre.Id));
                }else {
                    OrderItem oi = new OrderItem(
                        Quantity = 0,
                        Product2Id = pre.Product2Id,
                        Product2 = pre.Product2,
                        PricebookEntryId = pre.Id,
                        UnitPrice = pre.UnitPrice

                    );
                    orderItemList.add(oi);
                    orderItemMap.put(oi.PricebookEntryId, oi);
                }
            }
        }
        onFieldChange();
    }

    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    public void populateOrderItemMap() {
        orderItemMap = new Map<id,OrderItem>();
        if (orderRecord != null && orderRecord.OrderItems.size() > 0) {
            for (OrderItem oi : orderRecord.OrderItems) {
                orderItemMap.put(oi.PricebookEntryId, oi);
            }
        }
    }


    /**
     * @name OnFieldChange
     * @description
    **/
    public void onFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        pieData = new List<ChartHelper.ChartData>();
        total = 0;
        for (OrderItem oi : orderItemMap.values()) {
            if (oi.Quantity != 0) {
                total += oi.Quantity * oi.UnitPrice;
                ChartHelper.ChartData newPieData = new ChartHelper.ChartData(oi.Product2.Name, oi.Quantity * oi.UnitPrice);
                pieData.add(newPieData);
            }
        }

    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void selectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        loadPricebookEntry();
    }

    /**
     * @name Save
     * @description
    **/
    public void save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        Savepoint sp = Database.setSavepoint();

        if (orderRecord.Id != null) {
            Order orderToUpdate = new Order(
                                            Id = orderRecord.Id,
                                            AccountId = orderRecord.AccountId,
                                            Name = orderRecord.Name,
                                            EffectiveDate = orderRecord.EffectiveDate,
                                            Status = orderRecord.Status
                                            );
            
            List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
            List<OrderItem> orderItemsToDelete = new List<OrderItem>();

            for (OrderItem oi : orderItemMap.values()) {
                 if (orderRecord.OrderItems.contains(oi) && oi.Quantity == 0) {
                     orderItemsToDelete.add(oi);
                 } else if (oi.Quantity > 0) {
                    OrderItem newOI = new OrderItem(
                        OrderId = orderRecord.Id,
                        PricebookEntryId = oi.PricebookEntryId,
                        Quantity = oi.Quantity,
                        UnitPrice = oi.UnitPrice
                    );
                    orderItemsToUpdate.add(newOI);
                 }
            }

            try {
                delete orderItemsToDelete;
                update orderToUpdate;
                insert orderItemsToUpdate;
                
                
                orderItemMap.clear();
                orderItemList.clear();
                orderRecord = queryOrderRecord(orderRecord.Id);
                // loadOrderItemInit();
                loadPricebookEntry();


            } catch (DmlException ex) {
                if (sp != null) {
                    Database.rollback(sp);
                }
                System.debug(ex.getMessage());
                apexPages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Constants.ERROR_MESSAGE));
            }
        } //else {
        //     Order orderToInsert = new Order(
        //                                     AccountId = orderRecord.AccountId,
        //                                     Name = orderRecord.Name,
        //                                     EffectiveDate = orderRecord.EffectiveDate,
        //                                     Status = orderRecord.Status
        //                                 );
        //     try {
        //         insert orderToInsert;
        //     } catch (Exception ex) {
        //         if (sp != null) {
        //             Database.rollback(sp);
        //         }
        //         System.debug(ex.getMessage());
        //         apexPages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Constants.ERROR_MESSAGE));
        //     }

        //     List<OrderItem> orderItemsToInsert = new List<OrderItem>();
        //     for (OrderItem oi : orderItemMap.values()) {
        //         if (oi.Quantity > 0) {
        //             oi.OrderId = orderToInsert.Id;
        //             orderItemsToInsert.add(oi);
        //         }
        //     }
        //     try {
        //         insert orderItemsToInsert;
        //     } catch (Exception ex) {
        //         if (sp != null) {
        //             Database.rollback(sp);
        //         }
        //         System.debug(ex.getMessage());
        //         apexPages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Constants.ERROR_MESSAGE));
        //     }
        // }

    }


    /**
     * @name First
     * @description
    **/
    public void first(){
        standardSetController.first();
        loadOrderItemData();
    }


    /**
     * @name Next
     * @description
    **/
    public void next(){
        standardSetController.next();
        loadOrderItemData();

    }


    /**
     * @name Previous
     * @description
    **/
    public void previous(){
        standardSetController.previous();
        loadOrderItemData();
    }

    /**
     * @name Last
     * @description
    **/
    public void last(){
        standardSetController.last();
        loadOrderItemData();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean getHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean getHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer getTotalPages(){
        Decimal page = (Decimal) standardSetController.getResultSize()/standardSetController.getPageSize();
        return (Integer) page.round(System.RoundingMode.CEILING);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer getPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> getFamilyOptions(){
        List<SelectOption> familyOptions = new List<SelectOption>();
        familyOptions.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for (Schema.PicklistEntry o : Constants.PRODUCT_FAMILY) {
            familyOptions.add(new SelectOption(o.getValue(), o.getLabel()));
        }
        return familyOptions;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order queryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }
}

