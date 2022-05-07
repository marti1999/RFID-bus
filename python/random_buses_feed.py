import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

import random
from time import sleep
from random import uniform

# Fetch the service account key JSON file contents
cred = credentials.Certificate('secret-key.json')
# Initialize the app with a service account, granting admin privileges
firebase_admin.initialize_app(cred, {
    'databaseURL': "https://graphical-bus-348706-default-rtdb.europe-west1.firebasedatabase.app/"
})

ref = db.reference('buses')

def random_latitude():
    # returns a random latitude value of earth 
    return uniform(-90, 90)

def random_longitude():
    # returns a random longitude between -180 and 180
    return uniform(-180, 180)


def random_bus_data():
    dic_stops = {
        'stop_1': {'latitude': random_latitude(), 'longitude': random_longitude()},
        'stop_2': {'latitude': random_latitude(), 'longitude': random_longitude()},
        'stop_3': {'latitude': random_latitude(), 'longitude': random_longitude()},
        'stop_4': {'latitude': random_latitude(), 'longitude': random_longitude()},
        'stop_5': {'latitude': random_latitude(), 'longitude': random_longitude()},
        'stop_6': {'latitude': random_latitude(), 'longitude': random_longitude()},
        'stop_7': {'latitude': random_latitude(), 'longitude': random_longitude()},
        'stop_8': {'latitude': random_latitude(), 'longitude': random_longitude()},
        'stop_9': {'latitude': random_latitude(), 'longitude': random_longitude()},
        'stop_10': {'latitude': random_latitude(), 'longitude': random_longitude()},
    }

    return dic_stops

while True:
    for i in range(1, 10):
        stop_id = 'stop_' + str(i)
        dic_stops = random_bus_data()
        stop = dic_stops[stop_id]
        sleep(0.5)
        ref.child('bus{0}'.format(i)).set({'busId': str(i), 'busPeopleNumber': random.randint(1, 200), 'busTime': '12:00', 'busLatitude': stop['latitude'], 'busLongitude': stop['longitude']})


# import numpy as np
# from buslinesim import Simulation
# from scipy.stats import truncnorm

# stop_pos = np.arange(0, 30, 2)
# nb_stops = len(stop_pos)
# mean_stops = nb_stops/2.0
# std_stops = nb_stops/4.0
# stops_to_dest = lambda: np.round(truncnorm.rvs(-1, 1, loc=mean_stops, scale=std_stops))
# sim = Simulation(bus_stop_positions=stop_pos,
#                  time_between_buses=lambda: 20,
#                  nb_stops_to_dest=stops_to_dest,
#                  passenger_arrival_times=lambda : np.random.exponential(3.0),
#                  nb_buses=20)
# sim.run()