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
    //ApexPages.StandardSetController standardSetController;   //???????

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        orderItemList = new List<OrderItem>();
        getOrderItemList();
    }

    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    public void getOrderItemList() {
        orderItemList = [
                        SELECT Quantity, Product2.Family, Product2.Name, UnitPrice, Product2.Quantity_Remaining__c
                        FROM OrderItem
                        ];
    }


    /**
     * @name OnFieldChange
     * @description
    **/
    public void onFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total

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
        return null;
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

}