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
    
}