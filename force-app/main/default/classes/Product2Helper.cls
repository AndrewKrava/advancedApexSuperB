public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void afterUpdate(List<Product2> newList, List<Product2> oldList){

        //ToDo: Declare a List of Product2 records named needsAnnouncement
        List<Product2> needsAnnouncement =new List<Product2>();

        //ToDo: Declare a Map of Strings to Inventory_Setting__mdt records
        Map<String, Inventory_Setting__mdt> mapInventorySetting = new Map<String, Inventory_Setting__mdt>();

        //ToDo: Loop through a query of Inventory_Setting__mdt records and populate the Map with Name as the key
        for (Inventory_Setting__mdt item : [
                                            SELECT MasterLabel, Low_Quantity_Alert__c 
                                            FROM Inventory_Setting__mdt
                                            ]) {
            mapInventorySetting.put(item.MasterLabel, item);
        }

        //ToDo: Loop through the Products in newList
        // Use the corresponding Inventory Setting record to determine the correct Low Quantity Alert
        // If the Product's Quantity Remaining has been changed to less than the Low Quantity Alert
        //      add it to the needsAnnouncement list
        for (Integer i=0; i<newList.size(); i++) {
            if (newList[i].Quantity_Remaining__c != oldList[i].Quantity_Remaining__c &&
                newList[i].Quantity_Remaining__c < mapInventorySetting.get(newList[i].Family).Low_Quantity_Alert__c){
                needsAnnouncement.add(newList[i]);
            }
        }
        //ToDo: Pass records to the postAlerts method
        postAlerts(needsAnnouncement);

    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void postAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            // ToDo: Construct a new AnnouncementInput for the Chatter Group so that it:
            // expires in a day
            // does not notify users via email.
            // and has a text body that includes the name of the product followed by the INVENTORY_LEVEL_LOW constant
            ConnectApi.AnnouncementInput annInput = new ConnectApi.AnnouncementInput();
            annInput.expirationDate = Date.today();
            annInput.sendEmails = false;

            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            ConnectApi.MessageBodyInput inputBody = new ConnectApi.MessageBodyInput();
            inputBody.messageSegments = new List<ConnectApi.TextSegmentInput>();

            textSegmentInput.text = p.Name + Constants.INVENTORY_LEVEL_LOW;
            inputBody.messageSegments.add(textSegmentInput);
            annInput.body = inputBody;

            annInput.parentId = COLLABORATION_GROUP[0].Id;
            toPost.add(annInput);
        }
        // ToDo: Create and enqueue an instance of the announcementQueuable class with the list of Products
        AnnouncementQueueable newJob = new AnnouncementQueueable();
        newJob.toPost = toPost;
        System.enqueueJob(newJob);
    }
}
