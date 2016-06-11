# redpinr

Ruby on Rails and Particle Photon implementation of Redpin Java/Android/iOS realtime 
location system. See http://redpin.org/

## Particle Photon as Locator Tag

The Particle Photon is a wifi-enabled development microcontroller. The chip communicates
with cloud services, where you can see published events. The chip can also "subscribe"
to other events (webhook responses, for example).

See particle/wifiscanandsend.ino for custom Particle firmware. This sketch publishes 
wifi scan information every 30 seconds to the Particle cloud.

To receive this information from the Particle cloud we install a webhook on the 
Particle cloud that catches the "apscan" event and forwards the data 
to our Rails endpoint:

    POST http://<public_ip>:3000/apscan
    
This is redirected to the ReadingsController, which adds the readings to the
database.

## Testing with curl

### Creating Measurements and Readings

This is what the Particle webhook sends:

    curl -i -X POST -H "Content-Type: application/x-www-form-urlencoded" -d \
     'event=apscan&data=%7B%22mid%22%3A%2220160610232538%22%2C%22ssid%22%3A%22Black%20Log%20Network%22%2C%22bssid%22%3A%22881fa141bcd8%22%2C%22channel%22%3A11%2C%22rssi%22%3A-82%2C%22sectype%22%3A3%7D&published_at=2016-06-10T23%3A25%3A49.763Z&coreid=400028000547343232363230' \
     http://localhost:3000/apscan

Then check results via api:

    curl -i -X GET http://localhost:3000/api/v1/measurements

### Uploading a Map

    curl -i -X POST -H "Content-Type: application/json" -d \
    '{"map":{"name":"Bacich Room 3","url":"http://www.hellenicaworld.com/Italy/Literature/SRussellForbes/en/images/i-057l.jpg"}}' \
    http://localhost:3000/api/v1/maps

### Creating a Location

    curl -i -X POST -H "Content-Type: application/json" -d \
    '{"location":{"name":"Temple of Saturn","map_id":1,"map_x":300,"map_y":600,"accuracy":0}}' \
    http://localhost:3000/api/v1/locations

### Making a Fingerprint

    curl -i -X POST -H "Content-Type: application/json" -d \
    '{"fingerprint":{"measurement_id":1,"location_id":3}}' \
    http://localhost:3000/api/v1/fingerprints
