import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import postSingleSAApproval from '@salesforce/apex/ODRIntegration.postSingleSAApproval';
export default class PnetSaForm extends LightningElement {
    @api
    caseId;
    
    _record;

    get record() {
        return {
            saRecord: {
                phn: this._record.phn,
                specAuthType: this._record.specAuthType,
                justificationCodes: this.strToArr(this._record.justificationCodes),
                excludedPlans: this.strToArr(this._record.excludedPlans),
                effectiveDate: this.dateSfdcToOdr(this._record.effectiveDate),
                terminateDate: this.dateSfdcToOdr(this._record.terminateDate),
                maxDaysSupply: this._record.maxDaysSupply,
                maxPricePct: this._record.maxPricePct,
                saRequester: {
                    practIdRef: this._record.practIdRef,
                    practId: this._record.practId
                },
                specialItem: {
                    din: this._record.din,
                    rdp: this._record.rdp
                }
            }
        };
    }

    @api
    set record(value) {
        this._record = {
            phn: value.saRecord.phn,
            practId: value.saRecord.saRequester.practId,
            practIdRef: value.saRecord.saRequester.practIdRef,
            din: value.saRecord.specialItem.din,
            rdp: value.saRecord.specialItem.rdp,
            specAuthType: value.saRecord.specAuthType,
            justificationCodes: this.arrToStr(value.saRecord.justificationCodes),
            excludedPlans: this.arrToStr(value.saRecord.excludedPlans),
            effectiveDate: this.dateOdrToSfdc(value.saRecord.effectiveDate),
            terminationDate: this.dateOdrToSfdc(value.saRecord.terminationDate),
            maxDaysSupply: value.saRecord.maxDaysSupply,
            maxPricePct: value.saRecord.maxPricePct,
        };
    }

    dateOdrToSfdc(odrDateStr) {
        if (!odrDateStr) return null;
        return odrDateStr.replaceAll('/', '-');
    }

    dateSfdcToOdr(sfdcDateStr) {
        if (!sfdcDateStr) return null;
        return sfdcDateStr.replaceAll('-', '/');
    }

    arrToStr(arr) {
        return arr ? arr.join(',') : '';
    }

    strToArr(strValue) {
        return strValue.split(',').map(item => item.trim());
    }

    handleFormChange(event) {
        this._record[event.currentTarget.dataset.field] = event.target.value;
    }

    async handleSubmit() {
        this.template.querySelector('.btn-submit').disabled = true;

        try {
            let saResponse = await postSingleSAApproval({
                caseId: this.caseId,
                pnetSa: this.record
            });
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                mode: "sticky",
                variant: "error"
            }));
            this.template.querySelector('.btn-submit').disabled = false;
        }
        
    }
}