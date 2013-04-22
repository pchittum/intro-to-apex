public with sharing class WarehouseDataInstall {

    public WarehouseDataInstall() {}

    public static boolean getHasData() {
        return [SELECT Id from Merchandise__c].size() > 0;
    }
    
    public PageReference createData() {
        List<Merchandise__c> m = new List<Merchandise__c>();
        m.add(new Merchandise__c(Name='Laptop',Price__c=500,Quantity__c=1000));
        m.add(new Merchandise__c(Name='Desktop',Price__c=1000,Quantity__c=500));
        m.add(new Merchandise__c(Name='Tablet',Price__c=300,Quantity__c=5000));
        m.add(new Merchandise__c(Name='Rack Server',Price__c=3245.99,Quantity__c=500));
        m.add(new Merchandise__c(Name='Old Laptop',Price__c=345.99,Quantity__c=50));
        m.add(new Merchandise__c(Name='Deluxe Desktop',Price__c=1399.99,Quantity__c=250));
        m.add(new Merchandise__c(Name='Work Desktop',Price__c=1145.99,Quantity__c=750));        
        insert m;
        
        for (Integer i=0; i<=6; i++) {
            Invoice__c inv = new Invoice__c(Status__c=(i < 3 ? 'Closed' : 'Open'));
            insert inv;
            
            Line_Item__c li = new Line_Item__c
              (Name='i', Quantity__c=1, Merchandise__c=m[i].Id,Invoice__c=inv.Id);
            insert li;       
        }
       
        
        return null;
    }
    
    
    @isTest
    public static void testWarehouseDataInstall() {
        WarehouseDataInstall wdi = new WarehouseDataInstall();
        if(!WarehouseDataInstall.getHasData()) {
            wdi.createData();
        }
        System.assertEquals(true,WarehouseDataInstall.getHasData());
    }

}