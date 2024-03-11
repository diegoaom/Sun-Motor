@isTest
private class AccountOwnershipCheckerTest {

    @testSetup
    static void setupTestData() {

        Flow_Control__c flowControl = new Flow_Control__c(Name = 'Test', Disable_Flow_For_Testing__c = true);
        upsert flowControl;

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
        User user3 = new User(
            FirstName = 'Test',
            LastName = 'User3',
            Username = 'testuser3@altim.com',
            Email = 'testuser3@example.com',
            Alias = 'tuser3',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardProfile.Id
        );
        insert user3;

        List<Territory__c> territories = new List<Territory__c>{
            new Territory__c(Owner__c = user1.Id, Zip_Code__c = '12345'),
            new Territory__c(Owner__c = user2.Id, Zip_Code__c = '55555'),
            new Territory__c(Owner__c = user3.Id, Zip_Code__c = '55555')
        };
        insert territories;

        Account account = new Account(Name = 'Test Account', BillingPostalCode = '12345', OwnerId = user3.Id);
        insert account;

        Contact contact = new Contact(LastName = 'Test Contact', AccountId = account.Id, OwnerId = user3.Id);
        insert contact;

        Opportunity opportunity1 = new Opportunity(Name = 'Test Opportunity 1', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = account.Id, OwnerId = user2.Id);
        Opportunity opportunity2 = new Opportunity(Name = 'Test Opportunity 2', StageName = 'Closed - Won', CloseDate = Date.today(), AccountId = account.Id, OwnerId = user2.Id);
        Opportunity opportunity3 = new Opportunity(Name = 'Test Opportunity 3', StageName = 'Closed - Lost', CloseDate = Date.today(), AccountId = account.Id, OwnerId = user3.Id);
        insert new List<Opportunity>{opportunity1, opportunity2, opportunity3};
    }

    @isTest
    static void testCheckAccountOwnership() {

        Test.startTest();
        AccountOwnershipChecker checker = new AccountOwnershipChecker();
        checker.checkAccountOwnership();
        Test.stopTest();

        User user1 = [SELECT Id FROM User WHERE Username = 'testuser1@altim.com'];
        User user2 = [SELECT Id FROM User WHERE Username = 'testuser2@altim.com'];
        User user3 = [SELECT Id FROM User WHERE Username = 'testuser3@altim.com'];

        Account updatedAccount = [SELECT Id, OwnerId FROM Account WHERE Name = 'Test Account'];
        System.assertEquals(user1.Id, updatedAccount.OwnerId, 'Account owner should be updated');

        Contact updatedContact = [SELECT Id, OwnerId FROM Contact WHERE LastName = 'Test Contact'];
        System.assertEquals(user1.Id, updatedContact.OwnerId, 'Contact owner should be updated');

        Opportunity updatedOpportunity1 = [SELECT Id, OwnerId FROM Opportunity WHERE Name = 'Test Opportunity 1'];
        System.assertEquals(user1.Id, updatedOpportunity1.OwnerId, 'Opportunity owner should be updated');

        Opportunity updatedOpportunity2 = [SELECT Id, OwnerId FROM Opportunity WHERE Name = 'Test Opportunity 2'];
        System.assertEquals(user2.Id, updatedOpportunity2.OwnerId, 'Closed - Won opportunity owner should not be updated');

        Opportunity updatedOpportunity3 = [SELECT Id, OwnerId FROM Opportunity WHERE Name = 'Test Opportunity 3'];
        System.assertEquals(user3.Id, updatedOpportunity3.OwnerId, 'Closed - Lost opportunity owner should not be updated');
    }

    @isTest
    static void testExecute() {

        Test.startTest();
        String jobId = System.schedule('TestScheduledJob', '0 0 0 * * ?', new AccountOwnershipChecker());
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Job ID should not be null');

    }
}
