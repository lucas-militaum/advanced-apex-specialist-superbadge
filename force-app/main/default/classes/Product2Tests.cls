@isTest
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        PageReference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(new Product2());
        Product2Extension ext = new Product2Extension(stdcontroller);
        List<SelectOption> options = ext.GetFamilyOptions();

        System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size(), 'DEFAULT_ROWS should be equal to the number of rows on the page');
        ext.addRows();
        System.assertEquals(Constants.DEFAULT_ROWS*2, ext.productsToInsert.size(), 'Double of DEFAULT_ROWS should be equal to the number of rows on the page');

        for (Integer i=0; i<5; i++) {
            ext.productsToInsert[i].productRecord.Family = options[0].getValue();
            ext.productsToInsert[i].productRecord.isActive = true;
            ext.productsToInsert[i].productRecord.Initial_Inventory__c = 10;
            ext.productsToInsert[i].pricebookEntryRecord.UnitPrice = 2;
            ext.productsToInsert[i].pricebookEntryRecord.isActive = true;
            ext.productsToInsert[i].productRecord.Name = 'Test ' + Integer.valueof((Math.random()*100));
        }

        Test.startTest();
            ext.save();
        Test.stopTest();

        List<Product2> savedProducs = [SELECT Id, Name FROM Product2];

        System.Assert.areEqual(Constants.DEFAULT_ROWS, savedProducs.size(), 'DEFAULT_ROWS should be equal to the number of rows on the page');
    }

}