public with sharing class ApexBasedAdjudication extends AdjudicationStrategy {

    public ApexBasedAdjudication(SpecialAuthorityRequest sar) {
        super(sar);
    }

    public override void evaluate() {
        execApex(drug.Apex_Class__c);
    }
}
