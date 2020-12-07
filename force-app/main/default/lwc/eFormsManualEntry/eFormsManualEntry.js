import { LightningElement, track, api } from 'lwc';

export default class EFormsManualEntry extends LightningElement {
    @api caseNumber = '';
    @api 
    get eFormURL() {
        return 'https://pro.formview.io/#/ngpqnmobrpdcyou/drug';
    }
}