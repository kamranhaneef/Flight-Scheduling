import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveFlight from '@salesforce/apex/FlightController.saveFlight';

export default class FlightCreator extends LightningElement {
    @track departureIataCode;
    @track arrivalIataCode;

    @api flightSaved = false;
    @api flightDistance;
    @api departureLocation;
    @api arrivalLocation;


    handleDepartureChange(event) {
        this.departureIataCode = event.target.value;
    }

    handleArrivalChange(event) {
        this.arrivalIataCode = event.target.value;
    }

    validateFields() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }

    saveFlight() {
        if (!this.validateFields()) {
            this.showToast('Error', 'Please correct the errors on the form.', 'error');
            return;
        }

        saveFlight({ departureIataCode: this.departureIataCode, arrivalIataCode: this.arrivalIataCode })
            .then(result => {
                this.flightDistance = Math.round(result.Flight_Distance__c);
                this.departureLocation = result.Departure_IATA_Code__c;
                this.arrivalLocation = result.Arrival_IATA_Code__c;
                this.flightSaved = true;
                this.showToast('Success :)', 'Your flight has been created successfully.', 'success');
            })
            .catch(error => {
                const errorMessage = error.body ? error.body.message : JSON.stringify(error);
                this.showToast('Error :(', errorMessage, 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}