public with sharing class AccountOwnershipChecker implements Schedulable {

    private Map<String, List<String>> createTerritoryMap(){
        Map<String, List<String>> territoryMap = new Map<String, List<String>>();
        List<Territory__c> allTerritories = [SELECT owner__c, zip_code__c FROM Territory__c WITH SECURITY_ENFORCED];

        for(Territory__c territory : allTerritories) {
            String zipCode = territory.Zip_Code__c;
            String salesRep = territory.owner__c;

            if(!territoryMap.containsKey(zipCode)) {
                territoryMap.put(zipCode, new List<String>{salesRep});
            } else {
                List<String> salesReps = territoryMap.get(zipCode);
                if(!salesReps.contains(salesRep)) {
                    salesReps.add(salesRep);
                    territoryMap.put(zipCode, salesReps);
                }
            }
        }

        return territoryMap;
    }

    @TestVisible
    private void checkAccountOwnership(){
        Map<String, List<String>> territoryMap = createTerritoryMap();
        Set<String> territoryZipCodes = territoryMap.keySet();
        List<Account> matchingAccounts = [SELECT id, ownerId, BillingPostalCode, Name, 
                                           (SELECT Id, OwnerId FROM Contacts),
                                           (SELECT Id, OwnerId, StageName FROM Opportunities)
                                           FROM Account
                                           WHERE BillingPostalCode IN :territoryZipCodes WITH SECURITY_ENFORCED];

        List<Contact> contactsToUpdate = new List<Contact>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        for (Account acc : matchingAccounts) {
            String zipCode = acc.BillingPostalCode;
            String accountOwnerId = acc.OwnerId;

            if (territoryMap.containsKey(zipCode)) {
                List<String> territoryOwners = territoryMap.get(zipCode);

                if (!territoryOwners.contains(accountOwnerId)) {
                    Integer randomIndex = (Integer)Math.floor(Math.random() * territoryOwners.size());
                    String chosenOwner = territoryOwners[randomIndex];

                    acc.OwnerId = chosenOwner;

                    for (Contact con : [SELECT Id, OwnerId FROM Contact WHERE AccountId = :acc.Id]) {
                        Contact updatedContact = new Contact(Id = con.Id, OwnerId = chosenOwner);
                        contactsToUpdate.add(updatedContact);
                    }

                    for (Opportunity opp : [SELECT Id, OwnerId, StageName FROM Opportunity WHERE AccountId = :acc.Id AND StageName NOT IN ('Closed - Won', 'Closed - Lost')]) {
                        opp.OwnerId = chosenOwner;
                        opportunitiesToUpdate.add(opp);
                    }
                }
            }
        }
        
        update matchingAccounts;
        update contactsToUpdate;
        update opportunitiesToUpdate;
    }

    public void execute(SchedulableContext context) {
        checkAccountOwnership();
    }
}
