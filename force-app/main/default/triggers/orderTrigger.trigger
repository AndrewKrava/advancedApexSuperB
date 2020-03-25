/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (after update) {
    
    OrderHelper.AfterUpdate(Trigger.new, Trigger.old);
    
    List<Product2> listProduct = new List<Product2>();
    if ( Trigger.New != null ){
        for ( Order o : Trigger.New ){
            for ( OrderItem oi : [
                SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity
                FROM OrderItem
                WHERE OrderId = :o.Id
            ]){
                Product2 p = oi.Product2;
                 
                //p.Quantity_Ordered__c -= oi.Quantity;
                if (o.Status == 'Activated') {
                    p.Quantity_Ordered__c += oi.Quantity;
                    listProduct.add(p);
                }
                
                //if ( o.ActivatedDate != null){//listProduct.add(p);}
            }
        }
    }
   // try {update listProduct;}catch ( Exception e ){}
}