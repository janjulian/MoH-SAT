import { LightningElement, api } from 'lwc';
import fetchSAApprovalHistory from '@salesforce/apex/ODRIntegration.fetchSAApprovalHistory';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: 'Description', fieldName: 'description', type: 'text',  initialWidth: 120, hideDefaultActions: true },
  { label: 'Code', fieldName: 'dinrdp', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Auth Type', fieldName: 'specAuthType', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Effective Date', fieldName: 'effectiveDate', type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Termination Date', fieldName: 'terminationDate', type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Pract ID', fieldName: 'practId', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Pract ID Ref', fieldName: 'practIdRef', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'DaysSupply', fieldName: 'maxDaysSupply', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Excluded Plans', fieldName: 'excludedPlans', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Pharmacy', fieldName: 'pharmacyID', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'DEC', fieldName: 'decCode', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'CreatedBy', fieldName: 'createdBy', type: 'text', wrapText: true, hideDefaultActions: true }
];

export default class PharmanetApprovalHistory extends LightningElement {
  @api recordId;
  columns = columns;
  data = [];
  loaded = false;
  hasResults = false;
  completeAndNoResults = false;
  totalRecords = 0;

  error = {};
  isError = false;

  connectedCallback() {
    this.fetchItems();
  }

  async fetchItems() {
    let data = await fetchSAApprovalHistory({recordId: this.recordId, page: this.pageNumber, count: this.count, dinList: this.dinList})
    if (data && data.error == null) {
      console.log("saHistory:", data);
      const records = data.saRecords;
      this.totalRecords = data.totalRecords;

      if (this.totalRecords > 0) {
        this.completeAndNoResults = false;
        this.hasResults = true;
        let dataArray = [];
        records.forEach(record => {
          let item = {};
          item['description'] = record.specialItem.itemDescription;
          item['dinrdp'] = record.specialItem.din || record.specialItem.rdp;
          item['specAuthType'] = record.specAuthType;
          item['effectiveDate'] = record.effectiveDate;
          item['terminationDate'] = record.terminationDate;
          item['practId'] = record.saRequester.practId;
          item['practIdRef'] = record.saRequester.practIdRef;

          item['excludedPlans'] = "";
          record.excludedPlans.forEach(ep => {
            if (item['excludedPlans'] == "") {
              item['excludedPlans'] = ep;
            } else {
              item['excludedPlans'] += ", " + ep
            }
          });
          item['maxDaysSupply'] = record.maxDaysSupply;
          item['pharmacyID'] = record.saRequester.pharmacyID;
          // Not coming in response.
          item['decCode'] = record.saRequester.decCode;
          item['createdBy'] = record.createdBy;
          dataArray.push(item);
        });
        this.data = dataArray;
      } else {
        this.hasResults = false;
        this.completeAndNoResults = true;
      }
      this.loaded = true;
    } else {
      this.isError = true;
      this.loaded = true;
      this.error = data.error.errorMessage;
      const event = new ShowToastEvent({
        title: 'Pharmanet Error',
        message: data.error.errorMessage
      });
      this.dispatchEvent(event);
    }
  }
}