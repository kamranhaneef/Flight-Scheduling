/**
 * FlightController
 *
 * This class is used to manage flights in the application.
 *
 * Created by: Kamran Hanif
 * Created on: 13/11/2023
 * Version: 1
 */
public with sharing class FlightController {
    @AuraEnabled
    public static Flight__c saveFlight(String departureIataCode, String arrivalIataCode) {

        Decimal departureLatitude;
        Decimal departureLongitude;

        Decimal arrivalLatitude;
        Decimal arrivalLongitude;
        

        // Retrieve airports
        List<Airport__c> airports = FlightController.getAirportData(departureIataCode, arrivalIataCode);

        // We need to ensure we have both airports to calculate the distance.
        if (airports.size() != 2) {
            throw new AuraHandledException('Could not find airport information for one or both IATA codes provided.');
        }

        // The SOQL query doesn't guarantee order, so we must check which airport is which.
        for (Airport__c airport : airports) {
            if (airport.IATA_Code__c.equalsIgnoreCase(departureIataCode)) {
                departureLatitude = airport.Latitude__c;
                departureLongitude = airport.Longitude__c;
            } else if (airport.IATA_Code__c.equalsIgnoreCase(arrivalIataCode)) {
                arrivalLatitude = airport.Latitude__c;
                arrivalLongitude = airport.Longitude__c;
            }
        }

        Decimal calculatedFlightDistance = FlightController.getFlightDistance(departureLatitude, departureLongitude, arrivalLatitude, arrivalLongitude);

        // Save flight
        Flight__c flight = new Flight__c();
        flight.Departure_IATA_Code__c = departureIataCode;
        flight.Arrival_IATA_Code__c = arrivalIataCode;
        flight.Flight_Distance__c = calculatedFlightDistance;

        try {
            insert flight;
        } catch (DmlException e) {
            throw new AuraHandledException('An error occurred while saving the flight: ' + e.getMessage());
        }

        return flight;
    }

    public static List<Airport__c> getAirportData(String departure, String arrival) {
        if (String.isEmpty(departure) || String.isEmpty(arrival)) {
            throw new IllegalArgumentException('Departure and arrival IATA codes must not be null or empty.');
        }

        // Retrieve airports
        List<Airport__c> airports = [SELECT Id, Name, IATA_Code__c, Latitude__c, Longitude__c FROM Airport__c WHERE IATA_Code__c IN :new List<String>{departure, arrival}];

        return airports;
    }

    public static Decimal getFlightDistance(Decimal originLatitude, Decimal  originLongitude, Decimal destinationLatitude, Decimal destinationLongitude) {
        Decimal earthRadius = 6371; // in kilometers

        // Transform coordinates from degrees to radians
        Decimal latitudeRadians1 = originLatitude * Math.PI/180;
        Decimal latitudeRadians2 = destinationLatitude * Math.PI/180;
    
        // Latitude and longitude differences in radians
        Decimal latitudeDelta = (destinationLatitude - originLatitude) * Math.PI/180;
        Decimal longitudeDelta = (destinationLongitude - originLongitude) * Math.PI/180;
    
        Decimal a = Math.sin(latitudeDelta/2) * Math.sin(latitudeDelta/2) +
        Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) *
        Math.sin(longitudeDelta/2) * Math.sin(longitudeDelta/2);
    
        Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    
        // Calculate distance in kilometers
        Decimal distance = earthRadius * arc;
    
        return distance;
    }    

}