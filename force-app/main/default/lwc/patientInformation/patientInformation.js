import { LightningElement, api, wire } from 'lwc';
import verifyPatientInformationx from '@salesforce/apex/ODRIntegration.verifyPatientInformationx';

export default class PatientInformation extends LightningElement {
  @api recordId;
  verified = false;
  loaded = false;
  data = null;
  deceased = false;

  @wire(verifyPatientInformationx, { recordId: '$recordId' }) mapObjectToData({error,data}) {
    if (data) {
      console.log("PatientInformation:", data);
      this.data = data;

      // Re-work deceased
      this.deceased = this.data.deceased == true ? 'Yes' : 'No';

      this.loaded = true;
    }
  }
}