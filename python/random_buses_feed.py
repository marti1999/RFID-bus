from ast import increment_lineno
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import db

import random
from time import sleep
from random import uniform

# import pandas as pd
import requests
from bs4 import BeautifulSoup
import copy
import json
import os

from decimal import *

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
    
    def to_json(self):
        return {
            'id': self.id,
            'name': self.name,
            'lat': self.lat,
            'lng': self.lng
        }

class BusLine:
    def __init__(self, line_id, line_name, stops):
        self.line_id = line_id
        self.line_name = line_name
        
        self.current_stop_index = 0

        self.stop = stops[0]
        self.next_stop = stops[1]
        
        self.stops = stops

        getcontext().prec = 7
        
        self.lat = Decimal(self.stop.lat)
        self.lng = Decimal(self.stop.lng)

        print(f"{self.line_id} {self.line_name} {self.stop} {self.lat} {self.lng}")

        self.people_number = random.randint(100, 200) # Random number between 100 and 200

    def __str__(self):
        return f"{self.line_id} {self.line_name} {self.stop} {self.lat} {self.lng}"
    
    def __repr__(self):
        return f"{self.line_id} {self.line_name} {self.stop} {self.lat} {self.lng}"

    def to_json(self):
        return {
            'line_id': self.line_id,
            'line_name': self.line_name,
            'current_stop_index': self.current_stop_index,
            'stop': self.stop.to_json(),
            'next_stop': self.next_stop.to_json(),
            'stops': [stop.id for stop in self.stops],
            'lat': float(self.lat),
            'lng': float(self.lng),
            'people_number': self.people_number
        }

    def move_to_next_stop(self, speed = 1):
        
        increment_lat = Decimal((self.next_stop.lat - self.stop.lat) / speed)
        increment_lng = Decimal((self.next_stop.lng - self.stop.lng) / speed)

        if self.stop.lat > self.next_stop.lat: 
            print("stop lat is smaller than next stop lat")
            increment_lat = -increment_lat

        if self.stop.lng > self.next_stop.lng:
            print("stop lng is smaller than next stop lng")
            increment_lng = -increment_lng

        print(self.lat, self.lng, self.next_stop.lat, self.next_stop.lng)

        # Update the bus position in the database meter to meter until current lat and long are the same as the next stop lat and long
        while self.lat != self.next_stop.lat and self.lng != self.next_stop.lng:
            self.lat += increment_lat 
            self.lng += increment_lng

            self.update_bus()
            sleep(0.1)

            print(f"{self.line_id} {self.line_name} {self.stop} {self.lat} {self.lng}")


        print("Reached next stop")

        # Update the bus position in the database to the next stop
        self.people_number -= random.randint(1, 10) # Random number between 1 and 10 people leave the bus
        self.people_number += random.randint(1, 10) # Random number between 1 and 10 people entering the bus

        self.stop = self.next_stop # Update the current stop

        self.next_stop = self.stops[self.current_stop_index + 1] # Update the next stop
        self.current_stop_index += 1 # Update the current stop index
        self.update_bus() # Update the bus position in the database

    def update_bus(self):
        # doc_ref.document(value.line_id).set(value.to_json())
        ref.child(self.line_id).set(self.to_json())
        # ref.child(self.line_id).set(
        #     {
        #         'busId': self.line_id,
        #         'busLine': self.line_name, 
        #         'busPeopleNumber': self.people_number, 
        #         'busLatitude': float(self.lat), 
        #         'busLongitude': float(self.lng),
        #         'busStop': self.stop.name,
        #         'busNextStop': self.next_stop.name,
        #         'busNextStopLatitude': self.next_stop.lat,
        #         'busNextStopLongitude': self.next_stop.lng
                
        #     })


UAB_STOPS_ENDPOINT = "http://appbuses.accessibilitat-transports.uab.cat/?mod=linesviewer&page=lines_viewer_getmapdata&json=1"
UAB_LINE_STOPS_ENDPOINT = "http://appbuses.accessibilitat-transports.uab.cat/?mod=linesviewer&page=lines_viewer_busstop&ajax=1"

def read_bus_data():
    if os.path.exists("uab_bus_data.json"):
        print("Loading UAB bus data from file...")
        with open("uab_bus_data.json", "r") as f:
            data = json.load(f)
            return data['parades'], data['linies']
    else:
        print("Fetching UAB bus data...")
        # make a request to the endpoint
        response = requests.get(UAB_STOPS_ENDPOINT)
        # parse the response
        data = response.json()
        print(data)

        # save to json file 
        with open('uab_bus_data.json', 'w') as outfile:
            json.dump(data, outfile)

        # return the data
        return data['parades'], data['linies']

def get_lines_stop(data):
    lines = {}

    if os.path.exists("uab_bus_lines.json"):
        print("Loading UAB bus lines from file...")
        with open("uab_bus_lines.json", "r") as f:
            lines = json.load(f)
            return lines
    
    else:
        print("Fetching UAB bus lines...")

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

        # save to json file
        with open('uab_bus_lines.json', 'w') as outfile:
            json.dump(lines, outfile)

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

# db = firestore.client()

# doc_ref = db.collection(u'uab_bus_stops')

# for value in stops:
#     print(value)
#     doc_ref.document(value.id).set(value.to_json())

# doc_ref = db.collection(u'uab_bus_lines')

# for value in buses:
#     print(value)
#     doc_ref.document(value.line_id).set(value.to_json())

while True:
    for bus in buses:
        bus.move_to_next_stop(speed = 1)
        sleep(1)
        print("Current BUS: " + str(bus))
        # ref.child('bus{0}'.format(i)).set({'busId': str(i), 'busPeopleNumber': random.randint(1, 200), 'busTime': '12:00', 'busLatitude': stop['latitude'], 'busLongitude': stop['longitude']})
