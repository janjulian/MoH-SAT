sfdx force:org:create -v devhub -a sat-dev -f config/project-scratch-def.json -d 7 -s;
sfdx force:source:push -u sat-dev;
sfdx force:user:permset:assign -u sat-dev -n SA_Administrator;
sfdx force:apex:execute -u sat-dev -f scripts/apex/set-current-user.apex;
sfdx force:data:bulk:upsert -u sat-dev -s Drug__c -f data/drugs.csv -i Drug_Code__c -w 5;
sfdx force:data:bulk:upsert -u sat-dev -s Account -f data/accounts.csv -i Id -w 5;
sfdx force:data:bulk:upsert -u sat-dev -s Case -f data/cases.csv -i Id -w 5;
sfdx force:apex:execute -u sat-dev -f scripts/apex/assign-cases-to-queue.apex;
sfdx force:apex:execute -u sat-dev -f scripts/apex/add-form-questions.apex;
sfdx force:data:bulk:upsert -u sat-dev -s Adjudication_Criteria__c -f data/adjudicationcriteria.csv -i Id -w 5;
sfdx force:data:bulk:upsert -u sat-dev -s Drug_Template__c -f data/drugtemplates.csv -i Id -w 5;
sfdx force:apex:execute -u sat-dev -f scripts/apex/assign-drug-default-queues.apex;
sfdx force:org:open -u sat-dev;