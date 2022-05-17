#include <SPI.h>
#include <MFRC522.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <time.h>
#include <stdio.h>


#define SS_PIN  5  // ESP32 pin GIOP5 
#define RST_PIN 27 // ESP32 pin GIOP27 

#define LED_GREEN_PIN 32
#define LED_RED_PIN 33

#define BUS_ID 1
#define LINE_ID 1

#define PARADA_BAIXADA "3"

// Declaració modul RFID
MFRC522 rfid(SS_PIN, RST_PIN);

char jsonOutput[128];

// Variables per obtenir l'hora
const char* ntpServer = "pool.ntp.org";
const long  gmtOffset_sec = 0;
const int   daylightOffset_sec = 3600;

bool LECTOR_BUS = true;

void led_green_1s() {
  /**
   * Activa el led verd durant 1 segon.
   */
  digitalWrite(LED_GREEN_PIN, HIGH);   
  delay(1000);                       
  digitalWrite(LED_GREEN_PIN, LOW);    
  delay(10);                       
}

void led_red_1s() {
  /**
   * Activa el led vermell durant 1 segon.
   */
  digitalWrite(LED_RED_PIN, HIGH);   
  delay(1000);                       
  digitalWrite(LED_RED_PIN, LOW);    
  delay(10);                       
}

void initWiFi() {
  /**
   * Inicialitza el modul de xarxa Wifi
   * Durant el procés, activa el led vermell i al finalitzar activa el led verd per confirmar la connexió.
   */
  const char* ssid = "";
  const char* password = "";
 
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi ..");
  digitalWrite(LED_RED_PIN, HIGH); 
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  digitalWrite(LED_RED_PIN, LOW); 
  Serial.println("IP : ");
  Serial.println(WiFi.localIP());
  led_green_1s();
}

void led_red_fast() {
  /**
   * Activa el led vermell durant 1 dècima de segon.
   */
  digitalWrite(LED_RED_PIN, HIGH);   
  delay(100);                       
  digitalWrite(LED_RED_PIN, LOW);    
  delay(10);  
}

void led_green_fast() {
  /**
   * Activa el led verd durant 1 dècima de segon.
   */
  digitalWrite(LED_GREEN_PIN, HIGH);   
  delay(100);                       
  digitalWrite(LED_GREEN_PIN, LOW);    
  delay(10);  
}


bool check_uid(char *uid) {
  /**
   * Comproba si l'identificador de NFC es troba dins de la BD.
   * 
   * 
   * @param : Identificador de la targeta o dispositiu NFC.
   * @return : Boleà indicant si la validació i actualització són correctes.
   */

  // Obtenim l'hora
  struct tm timeinfo;
  char timeStringBuff[50];
  if(!getLocalTime(&timeinfo)){
    Serial.println("[ERROR] : Failed to obtain time");
    return false;
  }
  strftime(timeStringBuff, sizeof(timeStringBuff), "%B %d %Y %H:%M:%S", &timeinfo);
  String asString(timeStringBuff);

 
  // Var per enviar i rebre missatges HTTP
  HTTPClient http;
  http.useHTTP10(true);

  // Var per emmagatzemar les respostes en JSON
  DynamicJsonDocument doc(2048);

  // Definim crida HTTP per obtenir l'index de la parada actual
  String getStopPath = "https://graphical-bus-348706-default-rtdb.europe-west1.firebasedatabase.app/lines/" + String(LINE_ID) + ".json";
  
  http.begin(getStopPath.c_str());          // Enviem la crida
  int httpResponseCode = http.GET();        // Obtenim el codi de resposta
  deserializeJson(doc, http.getStream());   // Convertim el missatge de resposta a JSON

  // Guardem la informació de la parada actual
  String index_parada_actual = doc["busLineCurrentStop"]["stopId"].as<String>();
  float lat = doc["busLineLatitude"].as<float>();
  float lng = doc["busLineLongitude"].as<float>();
  Serial.println("[INFO] : Parada actual = " + String(index_parada_actual) + " amb coordenades (" + String(lat) + " , " + String(lng) + ")");


  // Definim crida per emmagatzemar el registre
  String serverPath = "https://graphical-bus-348706-2.europe-west1.firebasedatabase.app/rfid_cards/" + String(uid) + ".json";
  
  http.begin(serverPath.c_str());
  httpResponseCode = http.GET();

  if (httpResponseCode == 404 ) {
    Serial.println("[ERROR] : Response code " + String(httpResponseCode));
    return false;
  }

  // Convertim la resposta a objecte JSON
  deserializeJson(doc, http.getStream());

  int num_viatges = doc["viatges"].as<int>(); 

  // Si el numero de viatges es zero (null), la targeta no esta registrada.
  if(doc.as<String>() == "null") {
    Serial.println("[ERROR] : Targeta no registrada");
    return false;
  }  
  Serial.println("[INFO] : Numero de viatges : " + String(num_viatges));


  String url = "https://graphical-bus-348706-2.europe-west1.firebasedatabase.app/rfid_cards/" + String(uid) + ".json";
  http.begin(url.c_str());

  String jsonReturn;
  if(LECTOR_BUS == true) {
    // Actualitzem contador de viatges
    num_viatges++;
    doc["viatges"] = num_viatges;
    doc["historial_viatges"]["pujada"][String(timeStringBuff)]["busStop"] = String(index_parada_actual);  
    doc["historial_viatges"]["pujada"][String(timeStringBuff)]["busLine"] = String(LINE_ID);  
  } else {
    doc["historial_viatges"]["baixada"][String(timeStringBuff)] = PARADA_BAIXADA;  
  }
  jsonReturn = doc.as<String>();

  httpResponseCode = http.PATCH(String(jsonReturn));

  String payload;
  payload = http.getString();

  http.end();

  if (httpResponseCode == 200) {
    Serial.println("[OK !] : Viatges Updated " + String(httpResponseCode));
    return true;
  } else {
    Serial.println("[ERROR] : Response code " + String(httpResponseCode));
    return false;
  }
}


void printLocalTime(){
  struct tm timeinfo;
  if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return;
  }
  Serial.println(&timeinfo, "%A, %B %d %Y %H:%M:%S");
}

void setup() {
  Serial.begin(115200);

  // Init LEDs
  pinMode(LED_GREEN_PIN, OUTPUT);
  pinMode(LED_RED_PIN, OUTPUT);
  
  // Init Wifi
  initWiFi();
  
  SPI.begin(); // init SPI bus
  rfid.PCD_Init(); // init MFRC522

  // Set time
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  printLocalTime();

  // Inicialitzem el lector com si estigues dins del bus
  LECTOR_BUS = true;

  Serial.println("Tap an RFID/NFC tag on the RFID-RC522 reader");
}

void loop() {
  if (rfid.PICC_IsNewCardPresent()) { // new tag is available
    if (rfid.PICC_ReadCardSerial()) { // NUID has been readed
      MFRC522::PICC_Type piccType = rfid.PICC_GetType(rfid.uid.sak);

      led_red_fast();
      led_green_fast();
      
      // print UID in Serial Monitor in the hex format
      Serial.print("UID:");
      for (int i = 0; i < rfid.uid.size; i++) {
        Serial.print(rfid.uid.uidByte[i] < 0x10 ? " 0" : " ");
        Serial.print(rfid.uid.uidByte[i], HEX);
      }
      Serial.println();

      // Byte array to String HEX
      char output[(rfid.uid.size * 2) + 1];
      char *ptr = &output[0];
      int i;
      for (i = 0; i < rfid.uid.size; i++) {
          ptr += sprintf(ptr, "%02X", rfid.uid.uidByte[i]);
      }

      // Comproba si s'ha llegit una clau "admin" que canvia l'estat del lector
      // Per defecte és un lector de bus, en cas de passar la targeta el lector canvia a lector de parada
      if(String(output) == "9B54EAAB") {
        led_red_fast();
        led_green_fast();
        led_red_fast();
        led_green_fast();
        led_red_fast();
        led_green_fast();
        LECTOR_BUS = !LECTOR_BUS;
        Serial.println("[ADMIN] : Lector canviat correctament. Estat actual = " + String(LECTOR_BUS) + " (0=Parada, 1=Bus)");
      } else {  
        if (check_uid(output) == true) {
          led_green_1s();
        } else {
          led_red_1s();
        } 
      }

      rfid.PICC_HaltA(); // halt PICC
      rfid.PCD_StopCrypto1(); // stop encryption on PCD
      
    }
  }
}