import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

import random
from time import sleep
from random import uniform

# import pandas as pd
import requests
from bs4 import BeautifulSoup
import copy

# Fetch the service account key JSON file contents
cred = credentials.Certificate('secret-key.json')
# Initialize the app with a service account, granting admin privileges
firebase_admin.initialize_app(cred, {
    'databaseURL': "https://graphical-bus-348706-default-rtdb.europe-west1.firebasedatabase.app/"
})

ref = db.reference('lines')


class Stop:
    def __init__(self, id, name, lat, lng):
        self.id = id
        self.name = name

        if lat is not None:
            self.lat = float(lat)
        else:
            self.lat = 0.0

        if lng is not None:
            self.lng = float(lng)
        else:
            self.lng = 0.0
    
    def __str__(self):
        return self.name

class BusLine:
    def __init__(self, line_id, line_name, stops):
        self.line_id = line_id
        self.line_name = line_name
        
        self.current_stop_index = 0

        self.stop = stops[0]
        self.next_stop = stops[1]
        
        self.stops = stops
        
        self.lat = self.stop.lat
        self.lng = self.stop.lng

        self.people_number = random.randint(100, 200) # Random number between 100 and 200

    def __str__(self):
        return f"{self.line_id} {self.line_name} {self.stop} {self.lat} {self.lng}"
    
    def __repr__(self):
        return f"{self.line_id} {self.line_name} {self.stop} {self.lat} {self.lng}"

    def move_to_next_stop(self, speed = 1):
        difference_lat = self.next_stop.lat - self.stop.lat
        difference_lng = self.next_stop.lng - self.stop.lng

        print(f"{self.line_name} {self.stop} {self.next_stop} {difference_lat} {difference_lng}")

        ratio_lat = difference_lat / speed
        ratio_lng = difference_lng / speed

        # Update the bus position in the database meter to meter until reaching the next stop
        while self.lat != self.next_stop.lat or self.lng != self.next_stop.lng:
            # self.lat += uniform(-0.00001, 0.00001)
            # self.lng += uniform(-0.00001, 0.00001)
            self.lat += ratio_lat
            self.lng += ratio_lng

            self.update_bus()
            sleep(1)

        # Update the bus position in the database to the next stop
        self.people_number -= random.randint(1, 10) # Random number between 100 and 200
        self.stop = self.next_stop # Update the current stop

        self.next_stop = self.stops[self.current_stop_index + 1] # Update the next stop
        self.current_stop_index += 1 # Update the current stop index
        self.update_bus() # Update the bus position in the database

    def update_bus(self):
        ref.child(self.line_id).set(
            {
                'busId': self.line_id,
                'busLine': self.line_name, 
                'busPeopleNumber': self.people_number, 
                'busLatitude': self.lat, 
                'busLongitude': self.lng,
                'busStop': self.stop.name,
                'busNextStop': self.next_stop.name,
                
            })


UAB_STOPS_ENDPOINT = "http://appbuses.accessibilitat-transports.uab.cat/?mod=linesviewer&page=lines_viewer_getmapdata&json=1"
UAB_LINE_STOPS_ENDPOINT = "http://appbuses.accessibilitat-transports.uab.cat/?mod=linesviewer&page=lines_viewer_busstop&ajax=1"

def read_bus_data():
    # make a request to the endpoint
    response = requests.get(UAB_STOPS_ENDPOINT)
    # parse the response
    data = response.json()
    # return the data
    return data['parades'], data['linies']

def get_lines_stop(data):
    lines = {}

    for linia in data:
        # make post request to UAB_LINE_STOPS_ENDPOINT with the line id
        response = requests.post(UAB_LINE_STOPS_ENDPOINT, data={'IdLinia': linia['IdLinia']})
        # parse the html response
        html = response.text
        # parse the html response
        soup = BeautifulSoup(html, 'html.parser')
        # get all divs with atribute 'idparada' and get the text
        stops = soup.find_all('div', {'idparada': True})
        
        lines[linia['IdLinia']] = []

        # for each stop get the 'idparada' value
        for stop in stops:
            # get the idparada value
            idparada = stop['idparada']
            
            lines[linia['IdLinia']].append(idparada)

    return lines

def get_stops(data):
    stops = []
    for parada in data:
        stops.append(Stop(parada['IdParadaBus'], parada['NomParadaBus'], parada['LatParadaBus'], parada['LngParadaBus']))
    return stops

def initialize_buses(parades, linies, lines_with_stops):
    buses = []

    for linia in linies:
        stops = []
        linia_id = linia['IdLinia']

        for parada in parades:    
            if parada.id in lines_with_stops[linia_id]:
                stops.append(parada)
            
        buses.append(BusLine(linia['IdLinia'], linia['NomLinia'], copy.deepcopy(stops)))
        stops.clear()

    return buses

stops, bus_lines = read_bus_data()

lines_with_stops = get_lines_stop(bus_lines)

stops = get_stops(stops)

buses = initialize_buses(stops, bus_lines, lines_with_stops)

# print(buses)

while True:
    for bus in buses:
        bus.move_to_next_stop(speed = 1)
        sleep(1)
        print(bus)
        # ref.child('bus{0}'.format(i)).set({'busId': str(i), 'busPeopleNumber': random.randint(1, 200), 'busTime': '12:00', 'busLatitude': stop['latitude'], 'busLongitude': stop['longitude']})
