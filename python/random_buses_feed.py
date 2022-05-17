from ast import increment_lineno
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import db
import os
import json
import random
from time import sleep
from random import uniform

from datetime import datetime
from datetime import timedelta
# import pandas as pd
import requests
from bs4 import BeautifulSoup
import copy

from decimal import *

from pyproj import Geod

# Fetch the service account key JSON file contents
cred = credentials.Certificate('secret-key.json')
# Initialize the app with a service account, granting admin privileges
firebase_admin.initialize_app(cred, {
    'databaseURL': "https://graphical-bus-348706-default-rtdb.europe-west1.firebasedatabase.app/"
})

ref = db.reference('lines')


class Stop:
    def __init__(self, id, name, lat, lng, initial_bus_available_time):
        self.id = id
        self.name = name

        self.bus_available_time = initial_bus_available_time

        if lat is not None:
            self.lat = float(lat)
        else:
            self.lat = 0.0

        if lng is not None:
            self.lng = float(lng)
        else:
            self.lng = 0.0

    def update_bus_available_time(self, bus_time):
        # set bus_available_time to bus_time adding 5 minutes to it
        # parse bus_time to datetime
        bus_time = datetime.strptime(bus_time, '%H:%M')
        # add 5 minutes to bus_time
        bus_time = bus_time + timedelta(minutes=5)
        # convert bus_time to string
        bus_time = bus_time.strftime('%H:%M')

        self.bus_available_time = bus_time
        
    
    def __str__(self):
        return self.name
    
    def to_json(self):
        return {
            'stopId': self.id,
            'stopName': self.name,
            'stopLatitude': self.lat,
            'stopLongitude': self.lng,
            'stopBusAvailableTime': self.bus_available_time,
        }

class BusLine:
    def __init__(self, line_id, line_name, stops):
        self.line_id = line_id
        self.line_name = line_name
        
        self.current_stop_index = 0

        self.stop = stops[0]
        self.next_stop = stops[1]
        
        self.stops = stops
        self.geoid = Geod(ellps='WGS84')

        self.has_departed = False
        self.has_finished = False
    
        getcontext().prec = 7
        
        self.lat = Decimal(self.stop.lat)
        self.lng = Decimal(self.stop.lng)

        # list of strings with times from 8:00 to 20:00 in 15 minutes intervals
        self.bus_times = ["8:00", "8:15", "8:30", "8:45", "9:00", "9:15", "9:30", "9:45", "10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45", "12:00", "12:15", "12:30", "12:45", "13:00", "13:15", "13:30", "13:45", "14:00", "14:15", "14:30", "14:45", "15:00", "15:15", "15:30", "15:45", "16:00", "16:15", "16:30", "16:45", "17:00", "17:15", "17:30", "17:45", "18:00", "18:15", "18:30", "18:45", "19:00", "19:15", "19:30", "19:45", "20:00"]

        self.next_bus_time = 0

        print(f"{self.line_id} {self.line_name} {self.stop} {self.lat} {self.lng}")

        self.people_number = random.randint(100, 200) # Random number between 100 and 200

    def __str__(self):
        return f"{self.line_id} {self.line_name} {self.stop} {self.lat} {self.lng}"
    
    def __repr__(self):
        return f"{self.line_id} {self.line_name} {self.stop} {self.lat} {self.lng}"

    def to_json(self):
        return {
                'busLineId': self.line_id,
                'busLineName': self.line_name, 
                'busLinePeopleNumber': self.people_number, 
                'busLineLatitude': float(self.lat), 
                'busLineLongitude': float(self.lng),
                'busLineCurrentStop': self.stop.to_json(),
                'busLineNextStop': self.next_stop.to_json(),
                'busLineRoute':  [stop.id for stop in self.stops],
                'busLineNextBusTime':  self.bus_times[self.next_bus_time],
            }


    def add_distance(self, lat, lng, az, dist):
        lng_new, lat_new, return_az = self.geoid.fwd(lng, lat, az, dist)
        return lat_new, lng_new

    def move_to_next_stop(self, speed = 10):
        if self.current_stop_index == 1:
            print("Bus has departed from the first stop")
            self.has_finished = False
            self.has_departed = True

        time_it_takes_to_move = 0.0

        # Given a single initial point and terminus point, and the number of points, returns a list of longitude/latitude pairs describing npts equally spaced intermediate points along the geodesic between the initial and terminus points.
        r = self.geoid.inv_intermediate(self.lng,self.lat,self.next_stop.lng, self.next_stop.lat, speed)
        for lon,lat in zip(r.lons, r.lats): 
            self.lat = lat
            self.lng = lon
            self.update_bus()
            time = random.uniform(0.1, 0.5)
            sleep(time)
            time_it_takes_to_move += time


        print("Reached next stop")

        # Update the bus position in the database to the next stop
        self.people_number -= random.randint(1, 10) # Random number between 1 and 10 people left
        self.people_number += random.randint(1, 10) # Random number between 1 and 10 people entering
        
        self.people_number = max(self.people_number, 0) # Make sure people number is not negative
        
        self.stop = self.next_stop # Update the current stop

        # Update the current stop index
        if self.current_stop_index + 1 < len(self.stops):
            self.current_stop_index += 1
        else:
            self.current_stop_index = 0

        self.next_stop = self.stops[self.current_stop_index] # Update the next stop
        
        # get the next bus time
        if self.has_departed:
            self.next_bus_time += 1
            if self.next_bus_time >= len(self.bus_times):
                self.next_bus_time = 0
        
            self.stop.update_bus_available_time(self.bus_times[self.next_bus_time])
            
            
        self.update_bus() # Update the bus position in the database

        if self.current_stop_index == len(self.stops) - 1:
            self.has_finished = True
            self.has_departed = False
            print("Bus has departed")
        

    def update_bus(self):
        ref.child(self.line_id).set(self.to_json())


UAB_STOPS_ENDPOINT = "http://appbuses.accessibilitat-transports.uab.cat/?mod=linesviewer&page=lines_viewer_getmapdata&json=1"
UAB_LINE_STOPS_ENDPOINT = "http://appbuses.accessibilitat-transports.uab.cat/?mod=linesviewer&page=lines_viewer_busstop&ajax=1"

def read_bus_data():
    if os.path.exists('uab_bus_data.json'):
        print("Loading UAB bus data from file")
        with open('uab_bus_data.json', 'r') as f:
            data = json.load(f)
        return data['parades'], data['linies']

    # make a request to the endpoint
    response = requests.get(UAB_STOPS_ENDPOINT)
    # parse the response
    data = response.json()

    # save the data to a file
    with open('uab_bus_data.json', 'w') as f:
        json.dump(data, f)

    # return the data
    return data['parades'], data['linies']

def get_lines_stop(data):
    if os.path.exists('uab_bus_line_data.json'):
        print("Loading data from file")
        with open('uab_bus_line_data.json', 'r') as f:
            data = json.load(f)
        return data

    
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

    with open('uab_bus_line_data.json', 'w') as f:
        json.dump(lines, f)

    return lines

def get_stops(data):
    stops = []
    initial_time = "8:00"
    for parada in data:
        stops.append(Stop(parada['IdParadaBus'], parada['NomParadaBus'], parada['LatParadaBus'], parada['LngParadaBus'], initial_time))
        # add 5 minutes to the initial time
        initial_time = datetime.strptime(initial_time, "%H:%M")
        initial_time = initial_time + timedelta(minutes=5)
        initial_time = initial_time.strftime("%H:%M")

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
        bus.move_to_next_stop(speed = 10)
        sleep(1)
        print("Current BUS: " + str(bus))
        # ref.child('bus{0}'.format(i)).set({'busId': str(i), 'busPeopleNumber': random.randint(1, 200), 'busTime': '12:00', 'busLatitude': stop['latitude'], 'busLongitude': stop['longitude']})
