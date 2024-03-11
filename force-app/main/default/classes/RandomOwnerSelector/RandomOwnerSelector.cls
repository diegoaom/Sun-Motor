public without sharing class RandomOwnerSelector {

    @InvocableMethod(label='Select Random Owner' description='Returns a random Owner Id from a collection of Territory__c records')
    public static List<Id> selectRandomOwnerId(List<List<Territory__c>> territoryLists) {
        List<Id> randomOwnerId = new List<Id>();
    
        if (territoryLists != null && !territoryLists.isEmpty()) {
            Integer randomListIndex = (Integer)Math.floor(Math.random() * territoryLists.size());
            List<Territory__c> randomTerritoryList = territoryLists[randomListIndex];
            if (!randomTerritoryList.isEmpty()) {
                Integer randomTerritoryIndex = (Integer)Math.floor(Math.random() * randomTerritoryList.size());
                randomOwnerId.add(randomTerritoryList[randomTerritoryIndex].Owner__c);
            }
        }
    
        return randomOwnerId;
    }
}