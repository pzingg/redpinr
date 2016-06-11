// Particle firmware to scan and send data to cloud
char my_ssid[] = "newtwork-name";
char my_psk[] = "network-password";
byte mac[6];

void setup() {
  Serial.begin(9600);
  // wait_for_serial_port();
  
  Serial.println("setup");
  
  // Connects to a network secured with WPA2 credentials.
  // WiFi.setCredentials(my_ssid, my_psk);
  // WiFi.connect();
  
  WiFi.on();
  int tries = 10;
  while (tries > 0 && !WiFi.ready()) {
    delay(1000);
  }
  
  if (WiFi.ready()) {
    WiFi.macAddress(mac);
    Serial.print("Connected, MAC address is ");
    String macs = "";
    for (int i = 5; i >= 0; i--) {
      macs.concat(String::format("%02x", mac[i]));
    }
    Serial.println(macs.c_str());
  } else {
    Serial.println("Not connected");
  }
}

void loop() {
  scan_and_publish();
  delay(30000);
}

/* 
typedef enum {
    WLAN_SEC_UNSEC = 0,
    WLAN_SEC_WEP,
    WLAN_SEC_WPA,
    WLAN_SEC_WPA2,
    WLAN_SEC_NOT_SET = 0xFF
} WLanSecurityType;
*/

/* 
typedef struct WiFiAccessPoint {
   size_t size;
   char ssid[33];
   uint8_t ssidLength;
   uint8_t bssid[6];
   WLanSecurityType security;
   WLanSecurityCipher cipher;
   uint8_t channel;
   int maxDataRate;   // the mdr in bits/s
   int rssi;          // when scanning
};
*/

void wait_for_serial_port() {
  while (!Serial.available()) {
    Particle.process();
  }
}

void scan_and_publish() {
  String mid = Time.format(Time.now(), "%Y%m%d%H%M%S");
  WiFiAccessPoint aps[20];
  int found = WiFi.scan(aps, 20);
  Serial.print(found);
  Serial.println(" APs scanned.");
  for (int i = 0; i < found; i++) {
    WiFiAccessPoint& ap = aps[i];
    String bssid = "";
    for (int j = 0; j < 6; j++) {
      bssid.concat(String::format("%02x", ap.bssid[j]));
    }
    Serial.println(ap.ssid);
    Serial.println(bssid);
    Serial.println(ap.channel);
    Serial.println(ap.rssi);
    Serial.println(ap.security);
    String value = String::format("{\"mid\":\"%s\",\"ssid\":\"%s\",\"bssid\":\"%s\",\"channel\":%d,\"rssi\":%d,\"sectype\":%d}",
      mid.c_str(), ap.ssid, bssid.c_str(), (int)ap.channel, ap.rssi, (int)ap.security);
    Particle.publish("apscan", value, 3600, PRIVATE);
  }
}
