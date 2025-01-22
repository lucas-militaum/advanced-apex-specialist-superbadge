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
    public static void AfterUpdate(List<Product2> newList, List<Product2> oldList){
        //ToDo: Declare a List of Product2 records named needsAnnouncement
        List<Product2> needsAnnouncement = new List<Product2>();
        //ToDo: Declare a Map of Strings to Inventory_Setting__mdt records
        Map<String, Inventory_Setting__mdt> lowQuantityMap = new Map<String, Inventory_Setting__mdt>();
        //ToDo: Loop through a query of Inventory_Setting__mdt records and populate the Map with Name as the key
        for(Inventory_Setting__mdt iSetting : [select id, DeveloperName, Low_Quantity_Alert__c from Inventory_Setting__mdt]){
            lowQuantityMap.put(iSetting.DeveloperName, iSetting);
        }
        //ToDo: Loop through the Products in newList
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        for(Product2 newProduct : newList){
            //ToDo: Populate the Map with the Id of the Product as the key and the Product as the value
            productMap.put(newProduct.Id, newProduct);
        }
        // Use the corresponding Inventory Setting record to determine the correct Low Quantity Alert
        // If the Product's Quantity Remaining has been changed to less than the Low Quantity Alert
        //      add it to the needsAnnouncement list
        for(Product2 p : productMap.values()){
            Inventory_Setting__mdt iSetting = lowQuantityMap.get(p.Family);
            if(iSetting != null){
                if(p.Quantity_Remaining__c < iSetting.Low_Quantity_Alert__c){
                    needsAnnouncement.add(p);
                }
            }
        }
        //ToDo: If needsAnnouncement is not empty, call postAlerts passing in needsAnnouncement
        if(!needsAnnouncement.isEmpty()){
            //ToDo: Pass records to the postAlerts method
            postAlerts(needsAnnouncement);
        }

    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        try {
            List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
            for ( Product2 p : productList ){
                // ToDo: Construct a new AnnouncementInput for the Chatter Group so that it:
                // expires in a day
                // does not notify users via email.
                // and has a text body that includes the name of the product followed by the INVENTORY_LEVEL_LOW constant
                ConnectApi.AnnouncementInput ai = new ConnectApi.AnnouncementInput();
                ai.expirationDate = Date.today().addDays(1);
                ai.sendEmails = false;
                ai.parentId = COLLABORATION_GROUP[0].Id;
                ai.body = new ConnectApi.MessageBodyInput();
                ai.body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                textSegmentInput.text = p.Name + ' ' + Constants.INVENTORY_LEVEL_LOW;
                ai.body.messageSegments.add(textSegmentInput);
    
                toPost.add(ai);
            }
            // ToDo: Create and enqueue an instance of the announcementQueuable class with the list of Products
            AnnouncementQueueable q = new AnnouncementQueueable();
            q.toPost = toPost;
            System.enqueueJob(q);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}