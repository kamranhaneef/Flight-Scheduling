@isTest
private class FlightControllerTests {

    @testSetup
    static void setup() {
        List<Airport__c> airports = new List<Airport__c>();
        airports.add(new Airport__c(Name = 'London Heathrow', IATA_Code__c = 'LHR', Latitude__c = 51.4700, Longitude__c = -0.4543));
        airports.add(new Airport__c(Name = 'John F. Kennedy International Airport', IATA_Code__c = 'JFK', Latitude__c = 40.6413, Longitude__c = -73.7781));
        insert airports;
    }

    @isTest
    static void testSaveFlightPositive() {
        Test.startTest();
        Flight__c flight = FlightController.saveFlight('LHR', 'JFK');
        Test.stopTest();

        System.assert(flight.Id != null, 'Flight should be saved to the database.');
        System.assertEquals('LHR', flight.Departure_IATA_Code__c, 'Departure IATA code should be LHR.');
        System.assertEquals('JFK', flight.Arrival_IATA_Code__c, 'Arrival IATA code should be JFK.');
        System.assert(flight.Flight_Distance__c != null, 'Flight distance should be calculated.');
    }

    @isTest
    static void testSaveFlightNegative_InvalidIataCode() {
        Test.startTest();
        try {
            FlightController.saveFlight('LHR', 'INVALID');
            System.assert(false, 'An AuraHandledException should have been thrown.');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Could not find airport information for one or both IATA codes provided.'), 'Incorrect error message for invalid IATA code.');
        } catch (Exception e) {
            System.assert(false, 'An AuraHandledException was expected, but a different exception was thrown.');
        }
        Test.stopTest();
    }
}