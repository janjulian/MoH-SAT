import { LightningElement, api, wire } from 'lwc';
import getRequestDetails from '@salesforce/apex/RequestDetailsController.getRequestDetails';

export default class RequestDetails extends LightningElement {
    @api recordId;
    
    @wire(getRequestDetails, { caseId: '$recordId' })
    records;
}