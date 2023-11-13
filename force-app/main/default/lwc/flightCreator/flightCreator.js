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

    saveFlight() {
        saveFlight({ departureIataCode: this.departureIataCode, arrivalIataCode: this.arrivalIataCode })
            .then(result => {
                this.flightDistance=Math.round(result.Flight_Distance__c);
                this.departureLocation=result.Departure_IATA_Code__c;
                this.arrivalLocation=result.Arrival_IATA_Code__c;
                this.flightSaved=true;
                this.showToast('Success :)', 'Your flight has been created successfully.', 'success');
            })
            .catch(error => {
                this.showToast('Error :(', JSON.stringify(error), 'error');
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