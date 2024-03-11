@isTest
private class AccountOwnershipCheckerTest {
    @isTest
    static void testCheckAccountOwnership() {

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

        Test.startTest();
        AccountOwnershipChecker checker = new AccountOwnershipChecker();
        checker.checkAccountOwnership();
        Test.stopTest();

        Account updatedAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :account.Id];
        System.assertEquals(user1.Id, updatedAccount.OwnerId, 'Account owner should be updated');

        Contact updatedContact = [SELECT Id, OwnerId FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(user1.Id, updatedContact.OwnerId, 'Contact owner should be updated');

        Opportunity updatedOpportunity1 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opportunity1.Id];
        System.assertEquals(user1.Id, updatedOpportunity1.OwnerId, 'Opportunity owner should be updated');

        Opportunity updatedOpportunity2 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opportunity2.Id];
        System.assertEquals(user2.Id, updatedOpportunity2.OwnerId, 'Closed - Won opportunity owner should not be updated');

        Opportunity updatedOpportunity3 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opportunity3.Id];
        System.assertEquals(user3.Id, updatedOpportunity3.OwnerId, 'Closed - Lost opportunity owner should not be updated');
    }
    @isTest
    static void testExecute() {

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

        Territory__c territory = new Territory__c(Owner__c = user1.Id, Zip_Code__c = '12345');
        insert territory;

        Account account = new Account(Name = 'Test Account', BillingPostalCode = '12345', OwnerId = user1.Id);
        insert account;

        Test.startTest();
        AccountOwnershipChecker checker = new AccountOwnershipChecker();
        checker.execute(null); 
        Test.stopTest();

        Account updatedAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :account.Id];
        System.assertEquals(user1.Id, updatedAccount.OwnerId, 'Account owner should be updated');
    }
}
