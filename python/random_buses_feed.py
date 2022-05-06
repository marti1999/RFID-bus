import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

# Fetch the service account key JSON file contents
cred = credentials.Certificate('secret-key.json')
# Initialize the app with a service account, granting admin privileges
firebase_admin.initialize_app(cred, {
    'databaseURL': "https://graphical-bus-348706-default-rtdb.europe-west1.firebasedatabase.app/"
})

ref = db.reference('Database reference')
print(ref.get())

ref.push({'busId': '1', 'busPeopleNumber': '10', 'busTime': '12:00', 'busLatitude': '1', 'busLongitude': '1'})
