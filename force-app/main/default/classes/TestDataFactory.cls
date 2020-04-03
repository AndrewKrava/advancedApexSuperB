/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup constructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup chaterGroup = new CollaborationGroup(Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS, CollaborationType = 'Public');
        return chaterGroup;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> constructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        List<Product2> products = new List<Product2>();
        for (Integer i=0; i<cnt; i++) {
            Product2 p = new Product2(
                                        Name = 'Test Product ' + i,
                                        IsActive = true,
                                        Initial_Inventory__c = 10,
                                        Family = Constants.PRODUCT_FAMILY.get(Math.mod(i, Constants.PRODUCT_FAMILY.size())).getValue()
                                    );
            products.add(p);
        }
        return products;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> constructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 p : prods) {
            PricebookEntry prbEntry = new PricebookEntry(
                                                            Product2Id = p.Id,
                                                            Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
                                                            IsActive = true,
                                                            UnitPrice = 100
                                                        );
            pricebookEntries.add(prbEntry);
        }
        return pricebookEntries;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> constructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> accounts = new List<Account>();
        for (Integer i=0; i<cnt; i++) {
            Account a = new Account(Name = 'Account Test ' + i);
            accounts.add(a);
        }
        return accounts;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact>  constructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        if (cnt != accts.size()) {
            new HandledException('Cnt not equal of list size accts');
            return null;
        } else {
            List<Contact> contacts = new List<Contact>();
            for (Integer i=0; i<cnt; i++) {
                    Contact c = new Contact(
                                                AccountId = accts[i].Id,
                                                LastName = 'Contact Test ' + accts[i].Name + ' ' + i
                                            );
                    contacts.add(c);
            }
            return contacts;   
        }
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> constructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        if (cnt != accts.size()) {
            new HandledException('Cnt not equal of list size accts');
            return null;
        } else {    
            List<Order> orders = new List<Order>();
                for (Integer i=0; i<cnt; i++) {
                    Order o = new Order(
                                        AccountId = accts[i].Id,
                                        Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
                                        Name = 'Test Order ' + accts[i].Name + ' ' + i,
                                        Status = Constants.DRAFT_ORDER_STATUS,
                                        EffectiveDate = Date.today()
                                        );
                    orders.add(o);
                }
            return orders;
        }

    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> constructOrderItems(Integer cnt, List<PricebookEntry> pbes, List<Order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        if (cnt != pbes.size() && cnt != ords.size()) {
            new HandledException('Cnt not equal of list size pbes and not equal list size of ords');
            return null;
        } else {
            List<OrderItem> orderItems = new List<OrderItem>();
            for (Integer i=0; i<cnt; i++) {
                OrderItem oi = new OrderItem(
                                            PricebookEntryId = pbes[i].Id,
                                            //Product2Id = pbes[i].Product2Id,
                                            OrderId = ords[i].Id,
                                            Quantity = Constants.DEFAULT_ROWS,
                                            UnitPrice = pbes[i].UnitPrice
                                            );
                orderItems.add(oi);
            }  
            return orderItems;
        }
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void insertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
                
        CollaborationGroup groupCol = constructCollaborationGroup();
        insert groupCol;

        List<Product2> prods = constructProducts(cnt);
        insert prods;

        List<PricebookEntry> pbes = constructPricebookEntries(prods);
        insert pbes;

        List<Account> accts = constructAccounts(cnt);
        insert accts;
        
        List<Contact> con =  constructContacts(cnt, accts);
        insert con;

        List<Order> ords = constructOrders(cnt, accts);
        insert ords;

        List<OrderItem> orItems = constructOrderItems(cnt, pbes, ords);
        insert orItems;
    }

    public static void verifyQuantityOrderedGood(List<Product2> originProducts, List<Product2> newProducts, Integer quantityOrderes) {
        for (Product2 newP : newProducts) {
            for (Product2 originP : originProducts) {
                if (newP.Name == originP.Name) {
                    System.assertEquals(quantityOrderes, newP.Quantity_Ordered__c - originP.Quantity_Ordered__c, 'Expected ' + quantityOrderes + ' quantity ordered products!');
                }
                
            }
        }
    }
    public static void verifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
        System.assertEquals((updatedProduct.Quantity_Ordered__c - originalProduct.Quantity_Ordered__c), qtyOrdered);
    }

}