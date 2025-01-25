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
        this.orderRecord = (Order)standardController.getRecord();
        this.orderItemMap = new Map<id,OrderItem>();
        if ( this.orderRecord.Id != null ){
            this.orderRecord = queryOrderRecord(orderRecord.Id);
        }

        this.refreshStandarSetController();
        total = 0;

        for(orderItem ot : orderRecord.OrderItems){
            this.orderItemMap.put(ot.Product2Id, ot);
            if(ot.Quantity > 0){
                if(pieData == null){
                    pieData = new List<ChartHelper.ChartData>();
                }
                pieData.add(new ChartHelper.ChartData(ot.Product2.Name, ot.Quantity * ot.UnitPrice));
                total += ot.Quantity * ot.UnitPrice;
            }
        }
        this.loadData();
    }

    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    void refreshStandarSetController(){
        String query = 'SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c FROM PricebookEntry WHERE IsActive = TRUE';

        if(selectedFamily != null && selectedFamily != Constants.SELECT_ONE){
            query += ' AND Product2.Family = \'' + selectedFamily + '\'';
        }
        query += ' ORDER BY Name';
        standardSetController = new Apexpages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }

    void loadData() {
        orderItemList = new List<orderItem>();
        for(SObject obj : standardSetController.getRecords()){
            PricebookEntry pbe = (PricebookEntry)obj;

            if(orderItemMap.containsKey(pbe.Product2Id)){
                orderItemList.add(orderItemMap.get(pbe.Product2Id));
            }else{
                OrderItem oi = new OrderItem(
                    PricebookEntryId = pbe.Id,
                    Product2Id = pbe.Product2Id,
                    UnitPrice = pbe.UnitPrice,
                    Quantity = 0,
                    Product2 = pbe.Product2
                );
                orderItemList.add(oi);
                orderItemMap.put(pbe.Product2Id, oi);
            }
        }
    }

    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        for(orderItem oi : orderItemList){
            orderItemMap.put(oi.Product2Id, oi);
        }

        pieData = null;
        total = 0;
        for(orderItem oi : orderItemMap.values()){
            if(oi.Quantity > 0){
                if(pieData == null){
                    pieData = new List<ChartHelper.ChartData>();
                }
                pieData.add(new ChartHelper.ChartData(oi.Product2.Name, oi.Quantity * oi.UnitPrice));
                total += oi.Quantity * oi.UnitPrice;
            }
        }
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        this.refreshStandarSetController();
        this.loadData();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        Savepoint sp = Database.setSavepoint();
        try {
            if(orderRecord.Pricebook2Id == null){
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            upsert orderRecord;

            List<orderItem> orderItemsToUpsert = new List<ORderItem>();
            List<orderItem> orderItemsToDelete = new List<ORderItem>();

            for(OrderItem oi : orderItemMap.values()){
                if(oi.Quantity > 0){
                    if(oi.OrderId == null){
                        oi.OrderId = orderRecord.Id;
                    }
                    orderItemsToUpsert.add(oi);
                }else if(oi.Id != null){
                    orderItemsToDelete.add(new OrderItem(id=oi.Id));
                    oi.Id = null;
                }
            }

            upsert orderItemsToUpsert;
            delete orderItemsToDelete;
        } catch (Exception e) {
            Database.rollback(sp);
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, Constants.ERROR_MESSAGE));
        }
    }


    /**
     * @name First
     * @description
    **/
    public void First(){
        standardSetController.first();
        this.loadData();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
        standardSetController.next();
        this.loadData();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        standardSetController.previous();
        this.loadData();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
        standardSetController.last();
        this.loadData();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.GetHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.GetHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        if(standardSetController != null){
            Decimal totalSize = standardSetController.getResultSize();
            Decimal pageSize = standardSetController.getPageSize();
            Decimal pages = totalSize/pageSize;
            if(pages > 0){
                return (Integer)pages.round(System.RoundingMode.CEILING);
            }
            else{
                return 1;
            }            
        }
        return null;
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.GetPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        return options;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
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