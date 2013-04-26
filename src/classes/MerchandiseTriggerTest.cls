@isTest
public class MerchandiseTriggerTest {

	static testMethod void firstTest(){
		loadTestData();
	}

	static void loadTestData(){

		List<Account> accounts = Test.loadData(Account.sObjectType,'testAccounts');
		List<Contact> contacts = Test.loadData(Contact.sObjectType,'testContacts');

		for(Account a: [select Id,Name,Type from Account where name in : new List<String>{'This','That','The Other'}]){
			System.debug(a.Name +','+ a.Type);
		}

		for(Contact c: [select Id,FirstName,AccountId from Contact where LastName in : new List<String>{'Smith','Jenson','Johnson','Taylor','Butcher'}]){
			System.debug(c.AccountId);
		} 

	}

}