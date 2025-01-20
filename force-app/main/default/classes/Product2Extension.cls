public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}
    public String selectedFamily {get;set;}

    public Product2Extension(ApexPages.StandardController sc){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            ProductWrapper wrapper = new ProductWrapper();
            productsToInsert.add( wrapper );
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        System.debug('GetInventory - inicio');
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){
        Savepoint sp = Database.setSavepoint();
        try {
            List<Product2> prdsToInsert = new List<Product2>();
            List<PricebookEntry> priceBooksToInsert = new List<PricebookEntry>();
            for (ProductWrapper pWrapper : productsToInsert) {
                if(!String.isEmpty(pWrapper.productRecord.Name) && !String.isEmpty(pWrapper.productRecord.Family) && pWrapper.pricebookEntryRecord.UnitPrice != null && pWrapper.productRecord.Initial_Inventory__c != null && pWrapper.productRecord.IsActive){
                    prdsToInsert.add(pWrapper.productRecord);
                    PriceBookEntry pbe = pWrapper.priceBookEntryRecord;
                    pbe.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                    priceBooksToInsert.add(pbe);
                }
            }
            insert prdsToInsert;

            for (Integer i = 0; i < prdsToInsert.size(); i++) {
                Product2 prd = prdsToInsert[i];
                priceBooksToInsert[i].Product2Id = prd.Id;
            }
            insert priceBooksToInsert;
            
            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,Constants.ERROR_MESSAGE));
            Database.rollback(sp);
        }

        return null;
    }

    
    public List<SelectOption> GetFamilyOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        return options;
    }

    class ProductWrapper {
        public Product2 productRecord {get; set;}
        public PricebookEntry pricebookEntryRecord {get; set;}
        public productWrapper(){
            productRecord = new Product2(Initial_Inventory__c =0);
            pricebookEntryRecord = new PricebookEntry(Unitprice=0.0);
        }
    }

}