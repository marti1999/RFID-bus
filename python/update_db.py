import requests
import json
from requests.structures import CaseInsensitiveDict


# Kg / metres
CO2_COTXE = 0.121 / 1000
CO2_BUS = 0.053 / 1000

DATABASE_URL = "https://graphical-bus-348706-2.europe-west1.firebasedatabase.app/rfid_cards.json"
USER_DATABASE_URL = "https://firestore.googleapis.com/v1/projects/graphical-bus-348706/databases/(default)/documents/users/"

linia_1_parada_21 = {
    5: 1180,
    15: 1380,
    3: 1670,
    19: 2640,
    20: 3080,
    4: 3970,
    16: 4250,
    6: 4470,
    21: 5540,
    "estacio_ref": 21
}

linia_2_parada_21 = {
    1: 1420,
    17: 1800,
    28: 2860,
    10: 3160,
    22: 4000,
    24: 4400,
    9: 4970,
    18: 6130,
    2: 6480,
    21: 7800,
    "estacio_ref": 21
}

linia_7_parada_5 = {
    15: 200,
    3: 500,
    19: 1470,
    20: 1920,
    13: 2380,
    10: 2640,
    22: 3470,
    24: 3870,
    18: 4170,
    2: 4510,
    5: 5190,
    "estacio_ref": 5
}


dict_distancies = {
    1: linia_1_parada_21,
    2: linia_2_parada_21,
    7: linia_7_parada_5
}


def calcula_distancia_parades(origen_id, desti_id, linia_id):
    distancia_linia = dict_distancies[linia_id]

    if origen_id == desti_id:
        # Si puja i baixa a la mateixa parada, es comptabilitza el viatge màxim
        return distancia_linia[distancia_linia["estacio_ref"]]

    distancia_origen = distancia_linia[origen_id]
    distancia_desti = distancia_linia[desti_id]

    if distancia_desti > distancia_origen:
        return distancia_desti - distancia_origen
    else:
        distancia_restart = distancia_linia[distancia_linia["estacio_ref"]] - distancia_linia[origen_id]
        return distancia_restart + distancia_linia[desti_id]


def calcula_CO2(distancia):
    return distancia * CO2_COTXE - distancia * CO2_BUS


response = requests.get(DATABASE_URL)

if response.status_code != 200:
    print("[ERROR] : Bad acces to Firebase realtime DB. Status Code = " + str(response.status_code))
elif response.text == "null":
    print("[ERROR] : No data. Check URL request")

json_response = json.loads(response.text)

rfid_keys = json_response.keys()

for key in rfid_keys:
    pujada = list(json_response[key]["historial_viatges"]["pujada"].values())
    baixada = list(json_response[key]["historial_viatges"]["baixada"].values())

    user_id = json_response[key]["user_id"]

    if len(pujada) != len(baixada):
        print("[INFO] : El total 'picades' de pujades i baixades són diferents. S'ignorara el calcul")
        continue

    total_metres = 0.0
    total_CO2 = 0.0

    for viatge in range(len(baixada)):
        distancia = calcula_distancia_parades(origen_id=int(pujada[viatge]["busStop"]),
                                                  desti_id=int(baixada[viatge]),
                                                  linia_id=int(pujada[viatge]["busLine"]))
        total_CO2 += calcula_CO2(distancia)
        total_metres += distancia

    total_km = round((total_metres / 1000), 2)
    total_CO2 = round(total_CO2, 2)
    total_viatges = len(baixada)

    print("[INFO] : RFID Card = " + str(key) + ", has saved (Kg) CO2 = "
          + str(total_CO2) + ", and total (km) distance = " + str(total_km))

    update_km_url = USER_DATABASE_URL + str(user_id)\
                    + "/?updateMask.fieldPaths=km&updateMask.fieldPaths=co2saved&updateMask.fieldPaths=viatges"

    headers = CaseInsensitiveDict()
    headers["Accept"] = "application/json"
    headers["Content-Type"] = "application/json"

    data_km = "{\"fields\":{\"km\":{\"doubleValue\":\"" + str(total_km) + "\"},\"co2saved\":{\"doubleValue\":\""\
              + str(total_CO2) + "\"},\"viatges\":{\"integerValue\":\"" + str(total_viatges) + "\"}}}"
    update_request = requests.patch(update_km_url, headers=headers, data=data_km)

    if update_request.status_code != 200:
        print("[ERROR] : Bad acces to FireStore DB. Status Code = " + str(response.status_code))
