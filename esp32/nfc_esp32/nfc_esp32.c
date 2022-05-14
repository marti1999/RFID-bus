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

// Declaració modul RFID
MFRC522 rfid(SS_PIN, RST_PIN);

char jsonOutput[128];

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
  String serverPath = "https://graphical-bus-348706-2.europe-west1.firebasedatabase.app/rfid_cards/" + String(uid) + ".json";
  Serial.println(serverPath);
  HTTPClient http;
  http.useHTTP10(true);
  http.begin(serverPath.c_str());
  int httpResponseCode = http.GET();

  if (httpResponseCode>0 && httpResponseCode != 404) {
    
    // Parse response
    DynamicJsonDocument doc(2048);
    deserializeJson(doc, http.getStream());

    int num_viatges = doc["viatges"].as<int>(); 

    // Si el numero de viatges es zero (null), la targeta no esta registrada.
    if(num_viatges == 0) {
      Serial.println("[ERROR] : Targeta no registrada");
      return false;
    }
    
    Serial.println("Numero de viatges : " + String(num_viatges));
    
    // Actualitzem contador de viatges
    num_viatges++;

    http.end();

    String url = "https://graphical-bus-348706-2.europe-west1.firebasedatabase.app/rfid_cards/" + String(uid) + ".json";
    http.begin(url.c_str());


    String jsonReturn = "{\"viatges\":\"" + String(num_viatges) + "\"}";

    httpResponseCode = http.PATCH(String(jsonReturn));

    String payload;
    payload = http.getString();

    http.end();

    if (httpResponseCode>0 != 404) {
      Serial.println("[OK !] : Viatges Updated");
      return true;
    } else {
      Serial.println("[ERROR] : Response code " + String(httpResponseCode));
      return false;
    }
    
    
  }
  else {
    Serial.println("[ERROR] : Response code " + String(httpResponseCode));
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
        led_red_1s();
      }

      rfid.PICC_HaltA(); // halt PICC
      rfid.PCD_StopCrypto1(); // stop encryption on PCD
      
    }
  }
}