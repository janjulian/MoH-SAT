public with sharing class SarBuilder {
    private static Integer SORT_ORDER = 100;

    public static SpecialAuthorityRequest build(String bundleJsonStr) {
        Drug__c drug;
        Account provider;
        Account patient;
        Case saCase;
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        Eform.Bundle bundle = Eform.parse(bundleJsonStr);

        if (bundle.entry == null || bundle.entry.isEmpty()) return null;

        for (Eform.Entry bundleEntry : bundle.entry) {
            Eform.Resource resource = bundleEntry.resource;
            if (resource.resourceType.equalsIgnoreCase('Patient')) {
                patient = buildPatient(bundleEntry.resource);
            } else if (resource.resourceType.equalsIgnoreCase('Practitioner')) {
                provider = buildProvider(bundleEntry.resource);
            } else if (resource.resourceType.equalsIgnoreCase('Binary') && resource.contentType == 'application/pdf') {
                contentVersions.add(buildFile(bundleEntry.resource));
            } else if (resource.resourceType.equalsIgnoreCase('QuestionnaireResponse')) {
                requestDetails.addAll(buildRequestDetails(bundleEntry.resource));
            }
        }

        String drugCode = findDrugCode(requestDetails);
        List<Drug__c> drugs = [select Id, Name, Drug_Code__c from Drug__c where Drug_Code__c = :drugCode];
        String drugLabel = drugs.isEmpty() ? drugCode: drugs[0].Name;
        drug = drugs.isEmpty() ? new Drug__c() : drugs[0];

        String refNo = findReferenceNumber(bundle);
        
        saCase = buildCase(drug.Id, drugLabel, refNo);
        saCase.Provider_Fax__c = provider.Fax;
        
        contentVersions.add(buildFile(String.format(
            'bundle{0}.json', new String[] {
                String.isBlank(refNo) ? '' : '-' + refNo
            }), 
            Blob.valueOf(bundleJsonStr)
        ));

        return SpecialAuthorityRequest.build(drug, patient, provider, saCase, requestDetails, contentVersions);
    }

    public static Case buildCase(Id drugId, String drugLabel, String refNo) {
        Case caseRecord = new Case();
        caseRecord.Drug__c = drugId;
        caseRecord.Drug_Name__c = drugLabel;
        caseRecord.Subject = 'SA - ' + drugLabel;
        caseRecord.Origin = 'eForm';
        caseRecord.Status = 'Received';
        caseRecord.Description = 'Ref. No.: ' + refNo;
        return caseRecord;
    }

    public static Account buildPatient(Eform.Resource resource) {
        Account account = buildAccount(resource);

        String identifier = getIdentifier(resource.identifier);
        
        List<Account> existing = [select Id from Account where Patient_Identifier__pc = :identifier];
        account.Id = existing.isEmpty() ? null : existing[0].Id;
        
        account.Patient_Identifier__pc = identifier;
        account.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Account', 'Patient').getRecordTypeId();
        account.PersonBirthdate = Date.valueOf(resource.birthDate);
        return account;
    }

    public static Account buildProvider(Eform.Resource resource) {
        Account account = buildAccount(resource);

        String identifier = getIdentifier(resource.identifier);
        
        List<Account> existing = [select Id from Account where Provider_Identifier__pc = :identifier];
        account.Id = existing.isEmpty() ? null : existing[0].Id;
        
        account.Provider_Identifier__pc = identifier;
        account.RecordTypeId = SchemaUtil.getRecordTypeInfosByDeveloperName('Account', 'Provider').getRecordTypeId();
        return account;
    }

    private static Account buildAccount(Eform.Resource resource) {
        Account account = new Account();
        Eform.Name name = getName(resource.name);
        account.FirstName = name == null || name.given.isEmpty() ? '' : String.join(name.given, ' ');
        account.LastName = name == null ? '(EMPTY)' : name.family;

        account.Phone = getTelecom(resource.telecom, 'phone')?.value;
        account.Fax = getTelecom(resource.telecom, 'fax')?.value;

        Eform.Address address = getAddress(resource.address);
        account.PersonMailingStreet = address == null ? null : String.join(address.line, ' ');
        account.PersonMailingCity = address?.city;
        account.PersonMailingState = address?.state;
        account.PersonMailingPostalCode = address?.postalCode;
        return account;
    }

    public static List<Request_Detail__c> buildRequestDetails(Eform.Resource resource) {
        return buildRequestDetails(new List<String>(), resource.item);
    }

    private static List<Request_Detail__c> buildRequestDetails(List<String> questionIds, List<Eform.Item> qrItems) {
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();

        if (qrItems == null) return requestDetails;
        
        for (Eform.Item qri : qrItems) {
            List<String> newQuestionIds = new List<String>(questionIds);
            newQuestionIds.add(qri.linkId);

            if (qri.answer != null && qri.answer.isEmpty() == false) {
                requestDetails.addAll(buildRequestDetails(newQuestionIds, qri));
            } else {
                requestDetails.addAll(buildRequestDetails(newQuestionIds, qri.item)); 
            }
        }

        return requestDetails;
    }

    private static List<Request_Detail__c> buildRequestDetails(List<String> questionIds, Eform.Item qrItem) {
        List<Request_Detail__c> requestDetails = new List<Request_Detail__c>();
        
        String newQuestionId = String.join(questionIds, '.');

        for (Eform.Answer qra : qrItem.answer) {
            Request_Detail__c rd = new Request_Detail__c();
            rd.Question__c = qrItem.text;
            rd.Question_ID__c = newQuestionId;
            rd.Sort_Order__c = SORT_ORDER++;
            rd.String_Value__c = qra.valueString;
            rd.Decimal_Value__c = qra.valueDecimal;
            rd.Date_Value__c = qra.valueDate;
            rd.Datetime_Value__c = qra.valueDatetime;
            rd.Boolean_Value__c = qra.valueBoolean == true;
            requestDetails.add(rd);
        }

        return requestDetails;
    }
    
    public static ContentVersion buildFile(Eform.Resource resource) {
        return buildFile(resource.id + '.pdf', EncodingUtil.base64Decode(resource.data));
    }

    private static ContentVersion buildFile(String fileNameAndExt, Blob data) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = fileNameAndExt;
        contentVersion.Title = fileNameAndExt;
        contentVersion.VersionData = data;
        return contentVersion;
    }

    private static String findDrugCode(List<Request_Detail__c> requestDetails) {
        for (Request_Detail__c rd : requestDetails) {
            if (String.isNotBlank(rd.Question_ID__c) && rd.Question_ID__c.endsWithIgnoreCase('medication')) return rd.String_Value__c;
        }
        return 'No drug found.';
    } 

    private static String findReferenceNumber(Eform.Bundle bundle) {
        List<Eform.Tag> tags = bundle?.meta?.tag;
        
        String defaultCode = 'No reference number found.';
        
        if (tags == null) return defaultCode;
        
        for (Eform.Tag tag : tags) {
            if (tag.system_Z.contains('correlationId')) {
                defaultCode = tag.code;
            }
        }
        return defaultCode;
    }

    private static String getIdentifier(List<Eform.Identifier> identifiers) {
        String value = 'NULL_IDENTIFIER';
        if (identifiers == null) return value;
        for (Eform.Identifier identifier : identifiers) {
            value = identifier.value;
        }
        return value;
    }

    private static Eform.Name getName(List<Eform.Name> names) {
        if (names == null) return null;
        for (Eform.Name name : names) {
            return name;
        }
        return null;
    }

    private static Eform.Telecom getTelecom(List<Eform.Telecom> telecoms, String system_z) {
        if (telecoms == null) return null;
        for (Eform.Telecom telecom : telecoms) {
            if (telecom.system_Z.equalsIgnoreCase(system_z))
                return telecom;
        }
        return null;
    }

    private static Eform.Address getAddress(List<Eform.Address> addresses) {
        if (addresses == null) return null;
        for (Eform.Address address : addresses) {
            return address;
        }
        return null;
    }
}
