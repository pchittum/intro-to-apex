trigger MerchandiseTrigger on Merchandise__c (after update) {

	for (Merchandise__c merchandise : [SELECT
										Id,
										(SELECT
											Id
											FROM 
												Line_Items__r
											WHERE
												Invoice__r.Status__c = 'OPEN'
										)
										FROM
											Merchandise__c
										WHERE
											Status__c = 'Withdrawn' AND
											Id IN :Trigger.new]){
		
		if (merchandise.Line_Items__r.size() > 0 && Trigger.newMap.get(merchandise.Id).Status__c <> Trigger.oldMap.get(merchandise.Id).Status__c){
			Trigger.newMap.get(merchandise.Id).addError('You have open orders using this merchandise, close the orders first!');
		}
	}
}