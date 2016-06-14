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

## Maps

Experimenting with Quantum GIS (QGIS), an open-source mapping tool. Using QGIS
you can properly georeference a raster map of a building or campus.

See:
    
    http://www.kyngchaos.com/software/frameworks
    http://www.qgistutorials.com/en/docs/georeferencing_basics.html
    http://www.qgistutorials.com/en/docs/advanced_georeferencing.html
    http://www.qgistutorials.com/downloads/newyorkcity-washingtonsquarepark.jpg

Install GDAL, UnixImageIO, QGIS.  Enable OpenLayers and GDAL Georeferencer plugins.
This installs GDAL tools in /Library/Frameworks/GDAL.framework/Versions/1.11/Programs
And UnixImageIO tools in /Library/Frameworks/UnixImageIO.framework/Programs
Also manually built and installed Proj.4 tools in /usr/local/bin

Download Washington Square Park jpg image.

### Notes on Coordinate Systems

* EPSG:4326 or "WGS 84" or is a *geodetic* system and uses a coordinate system on the 
surface of a sphere or ellipsoid of reference (like a globe). WGS 84 is geocentric 
and globally consistent  within ±1 m. It is used by the Global Positioning System,
and Google Earth. OpenStreetMap *data* is stored in WGS 84.

* EPSG:3857 or "WGS 84 / Pseudo-Mercator" or "Spherical Mercator" or "Web Mercator", 
uses a coordinate system *projected* from the surface of the sphere or ellipsoid 
to a flat surface (like a map). It is used by Google Maps, for OpenStreetMap *tiles* 
and the WMS web service.

* There is also EPSG:4087 or "WGS 84 / 	World Equidistant Cylindrical", which is a 
pseudo plate carrée projection. Replaces EPSG:32662.

* And GeoTiff uses "CT_Mercator" or "Mercator (1SP)" which is EPSG:9804.

* We will store map overlays in UTM, since it's easy to find the actual real scale.

So if you are making a web map, which uses the tiles from Google Maps or 
tiles from the Open Street Map webservice, they will be in Sperical Mercator (EPSG:3857)
and hence your map has to have the same projection.

Go to Wikipedia and get lat and long for Washington Square Park.
Convert to EPSG:3857:

    echo "-73d59'51\" 40d43'51\"" | cs2cs +init=EPSG:4326 +to +init=EPSG:3857

Load OSM layer with EPSG:3857 projection and navigate to -8237364.02, 4972720.34.
Georeference points and start processing.

    listgeo -tfw newyorkcity-washingtonsquarepark_modified.tif 

Generates .tfw world file for that layer.

### Rendering Maps and Placing Locations

Since we're trying to be API-only, we'll probably use Leaflet.js to render maps
in the client.

## Testing with curl

### Creating Measurements and Readings

This is what the Particle webhook sends:

    curl -i -X POST -H "Content-Type: application/x-www-form-urlencoded" -d \
     'event=apscan&data=%7B%22mid%22%3A%2220160610232538%22%2C%22ssid%22%3A%22Black%20Log%20Network%22%2C%22bssid%22%3A%22881fa141bcd8%22%2C%22channel%22%3A11%2C%22rssi%22%3A-82%2C%22sectype%22%3A3%7D&published_at=2016-06-10T23%3A25%3A49.763Z&coreid=400028000547343232363230' \
     http://localhost:3000/apscan

Then check results via api:

    curl -i -X GET http://localhost:3000/api/v1/measurements

### Create a Map

You can upload a file and specify the world map to locate it:

    curl -i -X POST \
    --form "map[image_file]=@upload_test/bacich_elementary_school.jpg" \
    --form "map[world_file]=@upload_test/bacich.tfw" \
    --form "map[name]=Bacich Elementary School"
    --form "map[level]=G" \
    --form "map[crs]=UTM" \
    --form "map[zone]=10N" \
    http://localhost:3000/api/v1/maps
    
Or set things as separate parameters (url of uploaded image file):

    curl -i -X POST -H "Content-Type: application/json" -d \
    '{"map":{"url":"http://localhost:3000/overlays/kent_middle_school.jpg","name":"Kent Middle School","level":"G","crs":"UTM","zone":"10N","scale_x":0.15,"top_left_x":539620.9,"top_left_y":4200786.2}}' \
    http://localhost:3000/api/v1/maps

    curl -i -X POST -H "Content-Type: application/json" -d \
    '{"map":{"url":"http://localhost:3000/overlays/kentfield_district_office.jpg","name":"Kentfield District Office","level":"G","crs":"UTM","zone":"10N","scale_x":0.12,"top_left_x":539590.8,"top_left_y":4200643.2}}' \
    http://localhost:3000/api/v1/maps

Or update later:

    curl -i -X PATCH -H "Content-Type: application/json" -d \
    '{"map":{"level":"G","crs":"UTM","zone":"10N","scale_x":0.15,"top_left_x":539620.9,"top_left_y":4200786.2}}' \
    http://localhost:3000/api/v1/maps/3

### Creating a Location

    curl -i -X POST -H "Content-Type: application/json" -d \
    '{"location":{"name":"Temple of Saturn","map_id":2,"map_x":300,"map_y":600,"accuracy":0}}' \
    http://localhost:3000/api/v1/locations

### Making a Fingerprint

    curl -i -X POST -H "Content-Type: application/json" -d \
    '{"fingerprint":{"measurement_id":1,"location_id":2}}' \
    http://localhost:3000/api/v1/fingerprints
