import { LightningElement, api } from 'lwc';
import fetchPrescriptionHistory from '@salesforce/apex/ODRIntegration.fetchPrescriptionHistory';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: 'RxNo', fieldName: 'rxNumber', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Date Dispensed', fieldName: 'dateDispensed', type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Name', fieldName: 'genericName', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Prescriber', fieldName: 'prescriberName', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true },
  { label: 'Quantity', fieldName: 'quantity', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Refills', fieldName: 'refills', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'DINPIN', fieldName: 'dinpin', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Pharmacy', fieldName: 'dispensingPharmacyName', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true },
  { label: 'Direction', fieldName: 'directions', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Status', fieldName: 'rxStatus', type: 'text', wrapText: true, hideDefaultActions: true },
  // Claims History** not available
  { label: 'Days Supply', fieldName: 'daysSupply', hideDefaultActions: true },
  { label: 'Strength', fieldName: 'drugStrength', type: 'text', wrapText: true, hideDefaultActions: true },
  // Pract id/contact/details
  // Adverse
];

export default class PharmanetHistory extends LightningElement {
  @api recordId;
  columns = columns;
  data = [];
  loaded = false;
  count = '10';
  hasResults = false;
  completeAndNoResults = false;
  isFirstPage = true;
  isLastPage = false;
  totalRecords = 0;
  pageNumber = 1;
  totalPages = 0;

  // TODO: Populate via din list picker.
  dinList = [];
  error = {};
  isError = false;

  handleNextPage(event) {
    console.log('handle previous page', event);
    console.log(this.pageNumber, this.totalPages);
    if (this.pageNumber < this.totalPages) {
      this.pageNumber = this.pageNumber + 1;
    }
    this.handlePageChange();
  }
  handlePrevPage(event) {
    console.log('handle next page', event);
    console.log(this.pageNumber, this.totalPages);
    if (this.pageNumber > 1) {
      this.pageNumber = this.pageNumber - 1;
    }
    this.handlePageChange();
  }
  handlePageChange() {
    // Call the service and update stuff.
    this.fetchItems();
  }

  updatePageButtons() {
    console.log('PageNumber:', this.pageNumber, 'total', this.totalPages);
    if (this.pageNumber === 1) {
      this.isFirstPage = true;
    } else {
      this.isFirstPage = false;
    }
    if (this.pageNumber >= this.totalPages) {
      this.isLastPage = true;
    } else {
      this.isLastPage = false;
    }
  }

  // Count Options
  get countOptions() {
    return [
        { label: '10', value: '10' },
        { label: '50', value: '50' },
        { label: '75', value: '75' },
        { label: '100', value: '100' },
    ];
  }
  // Count change handler
  handleCountChange(event) {
    this.count = event.detail.value;
    this.fetchItems();
  }

  connectedCallback() {
    this.fetchItems();
  }

  fetchItems() {
    fetchPrescriptionHistory({recordId: this.recordId, page: this.pageNumber, count: this.count, dinList: this.dinList})
    .then(data => {
      if (data && data.error == null) {
        console.log("medHistory:", data.medHistory);
        const records = data.medHistory && data.medHistory.medRecords;
        this.totalRecords = data.medHistory && data.medHistory.totalRecords;
        this.totalPages = data.medHistory && data.medHistory.totalPages;

        if (this.totalRecords > 0) {
          this.completeAndNoResults = false;
          this.hasResults = true;
          let dataArray = [];
          records.forEach(record => {
            let item = {};

            item['rxNumber'] = record.rxNumber;
            item['quantity'] = record.quantity;
            item['refills'] = record.refills;
            item['dispensingPharmacyName'] = record.dispensingPharmacy.pharmacyId
              + ", " + record.dispensingPharmacy.name
              + ", T:" + record.dispensingPharmacy.phoneNumber
              + ", F:" + record.dispensingPharmacy.faxNumber;
            item['dateDispensed'] = record.dateDispensed;
            item['dinpin'] = record.dinpin;
            item['genericName'] = record.genericName;
            item['drugStrength'] = record.drugStrength;
            item['directions'] = record.directions;
            item['daysSupply'] = record.daysSupply;
            // cost claimed  N/A
            // cost accepted N/A
            item['prescriberName'] = record.prescriberInfo.name + ", "
            + ", " + record.prescriberInfo.licenseNo
            + ", T:" + record.prescriberInfo.phoneNumber
            + ", F:" + record.prescriberInfo.faxNumber;
            // benefit plan N/A
            item['rxStatus'] = record.rxStatus;
            dataArray.push(item);
          });
          this.data = dataArray;
        } else {
          this.hasResults = false;
          this.completeAndNoResults = true;
          this.pageNumber = 1;
        }
        this.loaded = true;
        this.updatePageButtons();
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
    });
  }
}