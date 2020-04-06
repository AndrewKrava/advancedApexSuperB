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
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        orderItemList = new List<OrderItem>();
        loadPricebookEntry();
        loadInitData();
        onFieldChange();
    }

    private void loadPricebookEntry() {
        String query = 'SELECT Id, UnitPrice, Product2Id, Product2.Name, Product2.Quantity_Remaining__c, Product2.Family ' +
                        'FROM PricebookEntry ' +
                        'WHERE IsActive = true ';
        standardSetController = new Apexpages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }
    
    private void loadInitData() {
        if (orderRecord != null && orderRecord.OrderItems.size() > 0) {
            for (OrderItem oi : orderRecord.OrderItems) {
                orderItemMap.put(oi.PricebookEntryId, oi);
            }
        }

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
                }
            }
            sortOrderItemByQuantity();
        }
    }

    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    public void getOrderItemList() {}


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
        for (OrderItem oi : orderItemList) {
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
    }

    /**
     * @name Save
     * @description
    **/
    public void save(){
        //ToDo: Implement logic to save the Order and populated OrderItems

    }


    /**
     * @name First
     * @description
    **/
    public void first(){

    }


    /**
     * @name Next
     * @description
    **/
    public void next(){
        standardSetController.next();

    }


    /**
     * @name Previous
     * @description
    **/
    public void previous(){

    }

    /**
     * @name Last
     * @description
    **/
    public void last(){

    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean getHasPrevious(){
        return null;
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
        return null;
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer getPageNumber(){
        return null;
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> getFamilyOptions(){
        return null;
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

    private void sortOrderItemByQuantity() {
        List<OrderItemWrapper> oiWrapperList = new List<OrderItemWrapper>();
        if (orderItemList.size() > 0) {
            for (OrderItem oi : orderItemList) {
                oiWrapperList.add(new OrderItemWrapper(oi));
            }
            orderItemList.clear();
            oiWrapperList.sort();
            for (OrderItemWrapper oiWrapper : oiWrapperList) {
                orderItemList.add(oiWrapper.orderItem);
            }
        }
    }

    public class OrderItemWrapper implements Comparable {
        OrderItem orderItem;
        public OrderItemWrapper(OrderItem oi){
            orderItem = oi;
        }
        public Integer compareTo(Object compareTo) {
            OrderItemWrapper compareToOI = (OrderItemWrapper) compareTo;
            Integer returnValue = 0;
            if (orderItem.Quantity > compareToOI.orderItem.Quantity) {
                returnValue = -1;
            } else if(orderItem.Quantity < compareToOI.orderItem.Quantity) {
                returnValue = 1;
            }
            return returnValue;
        }
    }
}

