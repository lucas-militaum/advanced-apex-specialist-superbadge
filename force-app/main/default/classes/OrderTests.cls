@isTest
private class OrderTests {
    @TestSetup
    static void SetupTestData(){
        TestDataFactory.InsertTestData(5);
    }

    @isTest
    public static void OrderUpdate_UnitTest() {
        
        Map<Id, Product2> originalProductMap = new Map<Id, Product2>([
            SELECT Id, Quantity_Ordered__c
            FROM Product2 ORDER BY Id]);

        List<Order> orders = [select Id, Status from Order];
        for (Order o : orders) {
            o.Status = Constants.ACTIVATED_ORDER_STATUS;
        }
        Test.startTest();
        update orders;
        Test.stopTest();
        
        List<AggregateResult> aggregatedResults = [
            SELECT Product2Id, SUM(Quantity) aggregatedQuantity
            FROM OrderItem GROUP BY Product2Id ORDER BY Product2Id];
        Map<Id, Product2> updatedProductMap = new Map<Id, Product2>([
            SELECT Id, Quantity_Ordered__c
            FROM Product2 ORDER BY Id]);

        for (Integer i = 0; i < updatedProductMap.size(); i++) {
            TestDataFactory.VerifyQuantityOrdered(
                originalProductMap.values()[i], updatedProductMap.values()[i], Integer.valueOf(aggregatedResults[i].get('aggregatedQuantity')));
        }
    }

    @isTest
    public static void OrderExtension_UnitTest() {
        Test.startTest();
        PageReference pageRef = Page.OrderEdit;
        
        Test.setCurrentPage(pageRef);
        Order o = [SELECT Id, Status FROM Order LIMIT 1];
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(o);
        
        OrderExtension ext = new OrderExtension(stdcontroller);
        
        System.Assert.areEqual(Constants.DEFAULT_ROWS, ext.orderItemList.size());
        
        ext.selectedFamily = 'Dessert';
        ext.SelectFamily();
        
        System.Assert.areEqual(1, ext.orderItemList.size());
        
        ext.OnFieldChange();
        ext.First();
        ext.Next();
        ext.Previous();
        
        ext.GetHasNext();
        ext.GetHasPrevious();
        ext.GetPageNumber();
        
        ext.GetTotalPages();
        ext.GetFamilyOptions();
        
        Test.stopTest();
        
    }
    
}