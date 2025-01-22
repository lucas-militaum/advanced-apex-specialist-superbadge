/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup collGroup = new CollaborationGroup(Name='TEST' + Constants.INVENTORY_ANNOUNCEMENTS, CollaborationType='Public');
        return collGroup;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        List<Product2> prods = new List<Product2>();
        for (Integer i = 0; i < cnt; i++) {
            Product2 prod = new Product2();
            prod.Name = 'Product ' + i;
            prod.IsActive = true;
            prod.Initial_Inventory__c = 10;
            prod.Family = Constants.PRODUCT_FAMILY[Math.mod(i, 3)].getValue();
            prod.Quantity_Ordered__c = 0;
            prods.add(prod);
        }

        return prods;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        
        for (Product2 prd : prods) {
            PriceBookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            pbe.Product2Id = prd.Id;
            pbe.IsActive = true;
            pbe.UnitPrice = (Decimal)100;
            pbes.add(pbe);
        }

        return pbes;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < cnt; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.Rating = 'Cold';
            accs.add(acc);
        }
        return accs;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> cons = new List<Contact>();
        for (Integer i = 0; i < cnt; i++) {
            Contact con = new Contact();
            con.LastName = 'Contact ' + i;
            con.AccountId = accts[Math.mod(i, accts.size())].Id;
            cons.add(con);
        }

        return cons;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> ords = new List<Order>();
        for (Integer i = 0; i < cnt; i++) {
            Order ord = new Order();
            ord.Name = 'Order ' + i;
            ord.AccountId = accts[Math.mod(i, accts.size())].Id;
            ord.EffectiveDate = Date.today();
            ord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            ord.Status = Constants.DRAFT_ORDER_STATUS;
            ords.add(ord);
        }
        return ords;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        List<OrderItem> ois = new List<OrderItem>();
        for (Integer i = 0; i < cnt; i++) {
            OrderItem ord = new OrderItem();
            ord.PricebookEntryId = pbes[Math.mod(i, pbes.size())].Id;
            ord.OrderId = ords[Math.mod(i, ords.size())].Id;
            ord.Quantity = Constants.DEFAULT_ROWS;
            ord.UnitPrice = (Decimal)100;

            ois.add(ord);
        }

        return ois;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        List<Account> accts = ConstructAccounts(cnt);
        insert accts;

        List<Contact> cons = ConstructContacts(cnt, accts);
        insert cons;

        List<Product2> prods = ConstructProducts(cnt);
        insert prods;

        List<PriceBookEntry> pbes = ConstructPricebookEntries(prods);
        insert pbes;

        List<Order> ords = ConstructOrders(cnt, accts);
        insert ords;

        List<OrderItem> ois = ConstructOrderItems(cnt, pbes, ords);
        insert ois;
    }

    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
        System.assertEquals(originalProduct.Quantity_Ordered__c + qtyOrdered, updatedProduct.Quantity_Ordered__c, 'Updated Qty should equal the sum of original with the qty ordered.');
    }

}