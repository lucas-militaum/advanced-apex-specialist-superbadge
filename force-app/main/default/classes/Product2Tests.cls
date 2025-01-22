@isTest (seeAllData=true)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        Test.startTest();
            ApexPages.StandardController stdcontroller = new ApexPages.StandardController(new Product2());
            Product2Extension ext = new Product2Extension(stdcontroller);
            List<SelectOption> options = ext.GetFamilyOptions();
            ext.addRows();
            for (Product2Extension.ProductWrapper pWrapper : ext.productsToInsert) {
                pWrapper.productRecord.Family = options[0].getValue();
                pWrapper.productRecord.isActive = true;
                pWrapper.productRecord.Initial_Inventory__c = 10;
                pWrapper.pricebookEntryRecord.UnitPrice = 2;
                pWrapper.pricebookEntryRecord.isActive = true;
                pWrapper.productRecord.Name = 'Test ' + Integer.valueof((Math.random()*100));
            }
            ext.save();
        Test.stopTest();

        System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size() , 'DEFAULT_ROWS should be equal to the number of rows on the page');
    }

}