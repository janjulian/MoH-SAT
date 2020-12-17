@isTest
public class ApexBasedAdjudicationTest {
    
    @isTest
    static void test_apex_invocation() {
        Drug__c drug = newDrug('Test Drug', 'ApexBasedAdjudicationTest.MockAdjudicationAction');
        insert drug;
        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(saCase);
        new ApexBasedAdjudication(sar).evaluate();
        system.assertEquals('Test case 1 +mock action executed', sar.saCase.Subject);
    }
    
    @isTest
    static void test_apex_invocation_with_error() {
        Drug__c drug = newDrug('Test Drug', 'ApexBasedAdjudicationTest.MockAdjudicationWithError');
        insert drug;
        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        SpecialAuthorityRequest sar = SpecialAuthorityRequest.build(saCase);

        try {
            new ApexBasedAdjudication(sar).evaluate();
            system.assert(false, 'An expected exception was not thrown.');
        } catch (Exception e) {
            system.assert(e.getMessage().contains('mock exception'));
        }
    }

    private static Drug__c newDrug(String name, String apexClass) {
        Drug__c drug = TestFactory.newDrug(name);
        drug.Adjudication_Strategy__c = 'Apex';
        drug.Apex_Class__c = apexClass;
        return drug;
    }

    private static Case queryCase(String subject) {
        return [select Id, Subject from Case where Subject = :subject limit 1][0];
    }
    
    public class MockAdjudicationAction implements AdjudicationAction {
        public void execute(SpecialAuthorityRequest sar) {
            sar.saCase.Subject += ' +mock action executed';
        }
    }

    public class MockAdjudicationWithError implements AdjudicationAction {
        public void execute(SpecialAuthorityRequest sar) {
            throw new MockException('mock exception');
        }
    }

    public class MockException extends Exception {}
}
