/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (after update) {
    
    List<Id> ids_Order = new List<Id>();
    for (Order order_item : Trigger.new) {
        if (order_item.Status == 'Activated') {
            ids_Order.add(order_item.Id);
        }
    }

    // List<AggregateResult> orderItems = [
    //                                 SELECT SUM(Quantity) sumQuantity, OrderId, Product2Id
    //                                 FROM OrderItem
    //                                 WHERE OrderId IN :ids_Order
    //                                 Group BY OrderId, Product2Id
    //                             ];
    // List<Id> product_ids = new List<Id>();
    // Object quantity = orderItems[0].get('sumQuantity');
    // System.debug('quantity object.... ' + quantity);
    // for (AggregateResult agrRes : orderItems) {
    //     //product_ids.add(agrRes.get('Product2Id'));
    //     System.debug('sum....' + agrRes.get('sumQuantity'));
    // }
    List<OrderItem> orderItems = [
                                    SELECT Quantity, OrderId, Product2Id
                                    FROM OrderItem
                                    WHERE OrderId IN :ids_Order
                                    ];
    List<Id> product_ids = new List<Id>();
    //Decimal quantity = 0;
    for (OrderItem order_Item : orderItems) {
        product_ids.add(order_Item.Product2Id);
        //quantity += order_Item.Quantity;
    }

    List<Product2> products_for_update = new List<Product2>();

    List<Product2> products = [
                                SELECT Id, Name, Quantity_Ordered__c
                                FROM  Product2
                                WHERE Id IN :product_ids
                            ];
    for (Product2 prod : products) {
        for (OrderItem order_Item : orderItems) {
            if (prod.Id == order_Item.Product2Id) {
                prod.Quantity_Ordered__c += order_Item.Quantity;
            }
        }
        products_for_update.add(prod);
    }
    try {
        update products_for_update;
    } catch (Exception ex) {
        
    }

//     OrderHelper.AfterUpdate(Trigger.new, Trigger.old);
    
//     List<Product2> listProduct = new List<Product2>();
//     if ( Trigger.New != null ){
//         for ( Order o : Trigger.New ){
//             for ( OrderItem oi : [
//                 SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity
//                 FROM OrderItem
//                 WHERE OrderId = :o.Id
//             ]){
//                 Product2 p = oi.Product2;
                 
//                 //p.Quantity_Ordered__c -= oi.Quantity;
//                 if (o.Status == 'Activated') {
//                     p.Quantity_Ordered__c += oi.Quantity;
//                     listProduct.add(p);
//                 }
                
//                 //if ( o.ActivatedDate != null){//listProduct.add(p);}
//             }
//         }
//     }
//    try {update listProduct;}catch ( Exception e ){}
}