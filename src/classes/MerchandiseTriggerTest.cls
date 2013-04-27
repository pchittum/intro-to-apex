@isTest
public class MerchandiseTriggerTest {
	
	static List<Merchandise__c> testMerchandise;
	static List<Invoice__c> testInvoices;
	static List<Line_Item__c> testLines;
	
	/*
	TEST 1: Update where validation is success
	Start State: Merchandise has status of Active, Invoices all Closed
	Action: update all test Merchandise with status of Withdrawn
	Tests: 
		- verify start state
		- All merchandise records tested have updated status value
	*/
	static testMethod void updateMerchandiseToWithdrawnOnClosedInvoices(){
		loadTestData('testInvoicesClosed');
		for (Merchandise__c m: testMerchandise) {
			System.assertNotEquals('Withdrawn',m.Status__c,'The start state of Merchandise status did not match the intended start state for this test');
			m.Status__c = 'Withdrawn';
		}
		Test.startTest();
		update testMerchandise;
		Test.stopTest();
		
		List<Merchandise__c> merchResults = [select Id,Status__c from Merchandise__c where Id in : testMerchandise];
		for (Merchandise__c m: merchResults) {
			System.assertEquals('Withdrawn',m.Status__c,'The end state of Merchandise Status should be Withdrawn');
		}
	}

	/*
	TEST 2: Update where validation fails
	Start State: Merchandise has status of Active, One invoice closed. Every Merchandise is related to Closed invoice
	Action: update all test Merchandise with status of Withdrawn
	Test: 
		- verify start state
		- Ensure flow does not pass the udpate statement in try block
		- Verify no merchandise records are updated to withdrawn
	*/	
	@isTest
	static void updateMerchandiseToWithdrawnWithOpenInvoices(){
		loadTestData();
		for (Merchandise__c m: testMerchandise) {
			System.assertNotEquals('Withdrawn',m.Status__c,'The start state of Merchandise status did not match the intended start state for this test');
			m.Status__c = 'Withdrawn';
		}
		Test.startTest();
		try {
			update testMerchandise;
			System.assert(false,'A test that should have resulted in an exception did not.');
		} catch (Exception e) {
			System.assert(e instanceof DMLException, 'The test ended in an exception other than DMLException' + e.getTypeName());
		} finally {
			Test.stopTest();
		}

	}

	/*
	TEST 3: Update where validation fails with all or none behavior disabled
	Start State: Merchandise has status of Active, One invoice closed. Every Merchandise is related to Closed invoice
	Action: update all test Merchandise with status of Withdrawn
	Test: 
		- verify start state
		- Ensure flow does not pass the udpate statement in try block
		- Verify no merchandise records are updated to withdrawn
	*/	
	@isTest
	static void updateMerchandiseToWithdrawnAllOrNoneFalse(){
		loadTestData();
		
		//cleanse three merchandise records to create a meaningful data set for purposes of testing some records save successfully at the same time as others fail
		Set<Id> successMerchIds = new Set<Id>();
		Set<Id> failureMerchIds = new Set<Id>();
		List<Line_Item__c> cleanUp = new List<Line_Item__c>();
		for (Merchandise__c m : [select id, Name, (select id from Line_Items__r where Invoice__r.Status__c = 'Open') from Merchandise__c limit 3]){
			successMerchIds.add(m.Id);
			cleanUp.addAll(m.Line_Items__r);
		}
		System.debug('this many to try to make successful' +successMerchIds.size()+ 'this many cleanups' +cleanup.size());
		delete cleanUp;
		//done creating three success merchandise records
		
		for (Merchandise__c m: testMerchandise) {
			System.assertNotEquals('Withdrawn',m.Status__c,'The start state of Merchandise status did not match the intended start state for this test');
			m.Status__c = 'Withdrawn';
		}
		System.debug(testMerchandise);
		Test.startTest();
		List<Database.SaveResult> srs = Database.update(testMerchandise,false);
		Test.stopTest();
		
		for (Database.SaveResult sr : srs) {
			if (sr.isSuccess()){
				System.assert(successMerchIds.contains(sr.getId()),'A Merchandise record that was successfully saved should not have been and was not part of the cleanup set.');
				System.debug('we have a success');
			} else {
				System.assert(!successMerchIds.contains(sr.getId()),'A Merchandise record that failed on save should have been successful and was part of the cleanup set.');
				failureMerchIds.add(sr.getId());
			}
		}
		
		for (Merchandise__c m: [select Id,Status__c from Merchandise__c where Id in : successMerchIds]) {
			System.assertEquals('Withdrawn',m.Status__c,'A merchandise record that was part of the success set has the wrong status value.');
		}		

		for (Merchandise__c m: [select Id,Status__c from Merchandise__c where Id in : failureMerchIds]) {
			System.assertNotEquals('Withdrawn',m.Status__c,'A merchandise record that was part of the failure set has the wrong status value.');
		}		
	}	
	
	static void loadTestData(){
		loadTestData('testInvoicesAll');
	}
	
	static void loadTestData(String invResName){

		testMerchandise = Test.loadData(Merchandise__c.sObjectType,'testMerchandise');
		testInvoices = Test.loadData(Invoice__c.sObjectType, invResName);
		testLines = new List<Line_Item__c>();
		
		for(Invoice__c inv: testInvoices){
			for(Merchandise__c m : testMerchandise){
				testLines.add(new Line_Item__c(Name='1',Merchandise__c=m.Id,Invoice__c=inv.Id,Quantity__c=1));
			}
		} 
		insert testLines;
		System.debug('Merchandise Count: ' + testMerchandise.size() + 'First 10 Merchandise: ' + testMerchandise);
		System.debug('Invoices Count: ' + testInvoices.size() + 'First 10 Invoices: ' + testInvoices);
		System.debug('Line Items Count: ' + testLines.size() + 'First 10 Merchandise: ' + testLines);
	}
}