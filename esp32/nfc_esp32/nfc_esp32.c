#include <SPI.h>
#include <MFRC522.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>


#define SS_PIN  5  // ESP32 pin GIOP5 
#define RST_PIN 27 // ESP32 pin GIOP27 

#define LED_GREEN_PIN 32
#define LED_RED_PIN 33

#define APY_KEY = AIzaSyAY87vG_P_n9zzGTNOuzVygIbj07FfiZwI
#define PROJECT_ID = graphical-bus-348706
#define PROJECT_NUMBER = 964587985452

MFRC522 rfid(SS_PIN, RST_PIN);

byte Usuario1[7]= {0x53, 0x5A, 0x2E, 0x69, 0x70, 0x00, 0x01} ;

char jsonOutput[128];

void leds_1s(){
  Serial.print("Leds1s");
  digitalWrite(LED_RED_PIN, HIGH); 
  delay(480);
  digitalWrite(LED_RED_PIN, LOW);
  delay(10); 
  digitalWrite(LED_GREEN_PIN, HIGH);                       
  delay(480); 
  digitalWrite(LED_GREEN_PIN, LOW);    
  delay(10); 
}

void initWiFi() {
  /**
   * Inicialitza el modul de xarxa Wifi
   * Durant el procés, activa el led vermell i al finalitzar activa el led verd per confirmar la connexió.
   */
  const char* ssid = "Casa_Garrofe1";
  const char* password = "garrofeurrutia";
 
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
   * @return : Bolèa indicant si la validació i actualització és correcte.
   */
  String serverPath = "https://firestore.googleapis.com/v1/projects/graphical-bus-348706/databases/(default)/documents/rfid_cards/" + String(uid);
  HTTPClient http;
  http.useHTTP10(true);
  http.begin(serverPath.c_str());
  int httpResponseCode = http.GET();

  if (httpResponseCode>0 && httpResponseCode != 404) {
    
    // Parse response
    DynamicJsonDocument doc(2048);
    deserializeJson(doc, http.getStream());

    int num_viatges = doc["fields"]["viatges"]["integerValue"].as<int>();    
    
    Serial.println("Numero de viatges : " + String(num_viatges));
    
    // Actualitzem contador de viatges
    num_viatges++;

    http.end();

    String url = "https://firestore.googleapis.com/v1/projects/graphical-bus-348706/databases/(default)/documents/rfid_cards/" + String(uid) + "/?updateMask.fieldPaths=viatges";
    HTTPClient http2;
    http2.begin(url);
    http2.addHeader("Content-Type", "application/json");
    http2.addHeader("Accept", "application/json");


    String jsonReturn = "{\"fields\":{\"viatges\":{\"integerValue\":\"" + String(num_viatges) + "\"}}}";

    httpResponseCode = http2.PATCH(String(jsonReturn));

    String payload;
    payload = http2.getString();

    http2.end();

    if (httpResponseCode>0 != 404) {
      Serial.print("Viatges Updated OK");
      return true;
    } else {
      Serial.print("Viatges ERROR");
      return false;
    }
    
    
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
    return false;
  }

  return true;
  
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

  Serial.println("Tap an RFID/NFC tag on the RFID-RC522 reader");
}

void loop() {
  if (rfid.PICC_IsNewCardPresent()) { // new tag is available
    if (rfid.PICC_ReadCardSerial()) { // NUID has been readed
      MFRC522::PICC_Type piccType = rfid.PICC_GetType(rfid.uid.sak);
      // Serial.print("RFID/NFC Tag Type: ");
      // Serial.println(rfid.PICC_GetTypeName(piccType));

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

      // Output conte String amb el UID
      if(check_uid(output) == true) {
        led_green_1s();
      } else {
        Serial.print("ERROR");
        led_red_1s();
      }

      rfid.PICC_HaltA(); // halt PICC
      rfid.PCD_StopCrypto1(); // stop encryption on PCD
      
    }
  }
}