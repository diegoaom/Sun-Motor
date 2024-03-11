@isTest
private class RandomOwnerSelectorTest {
    @isTest
    static void testSelectRandomOwnerId() {

        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Username = 'testuser1@altim.com',
            Email = 'testuser1@example.com',
            Alias = 'tuser1',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardProfile.Id
        );
        insert user1;
        User user2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Username = 'testuser2@altim.com',
            Email = 'testuser2@example.com',
            Alias = 'tuser2',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardProfile.Id
        );
        insert user2;

        List<Territory__c> territories1 = new List<Territory__c>{
            new Territory__c(Owner__c = user1.Id, Zip_Code__c = '12345'),
            new Territory__c(Owner__c = user2.Id, Zip_Code__c = '67890')
        };
        List<Territory__c> territories2 = new List<Territory__c>{
            new Territory__c(Owner__c = user2.Id, Zip_Code__c = '65590'),
            new Territory__c(Owner__c = user1.Id, Zip_Code__c = '62390')
        };
        insert territories1;
        insert territories2;

        Test.startTest();
        List<Id> result = RandomOwnerSelector.selectRandomOwnerId(new List<List<Territory__c>>{territories1, territories2});
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Expected result to contain exactly 1 Id');
        System.assertNotEquals(null, result[0], 'Returned Id should not be null');
        System.assert(territories1[0].Owner__c == result[0] || territories1[1].Owner__c == result[0]
                      || territories2[0].Owner__c == result[0] || territories2[1].Owner__c == result[0],
                      'Returned Id should be one of the Owner Ids from the input territories');
    }
}
