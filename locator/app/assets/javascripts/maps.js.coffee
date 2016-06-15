# Utility functions wrapping proj4js projections
getEpsgId = (zone) ->
  zn = zone.slice(0, -1)
  if zn.length < 2
    zn = "0" + zn
  ns = zone.slice(-1)
  if ns == "N"
    return "EPSG:326" + zn;
  else
    return "EPSG:327" + zn;

lngLatToUTM = (lng, lat, zone) ->
  if zone == null
    zone = Math.floor((lng + 180) / 6) + 1
    if lng == 180
      zone = 60
    ns = "N"
    if lat < 0
      ns = "S"
    zone += ns;

  epsgId = getEpsgId(zone)
  zn = zone.slice(0, -1)
  proj4.defs(epsgId, "+title=UTM Zone " + zone + " +proj=utm +zone=" + zn + " +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
  coords = proj4('WGS84', epsgId, [lng, lat])
  return new UtmPosition(zone, coords[0], coords[1])

webMercatorToUTM = (x, y) ->
  lngLat = proj4('EPSG:3857', 'WGS84', [x, y])
  return lngLatToUTM(lngLat[0], lngLat[1])


# Wrap zone, x, and y
class UtmPosition
  constructor: (@zone, @x, @y) ->


# Wrap parameters necessary for Leaflet imageOverlay call
class Overlay
  constructor: (@url, @level, @w, @h, scale, @zone, @c, @f, @d=0, @b=0) ->
    @a = scale;
    @e = -scale
    @bounds = @getLatLngBounds()
    @center = [(@bounds[0][0] + @bounds[1][0])/2.0, (@bounds[0][1] + @bounds[1][1])/2.0]

  getLatLngBounds: ->
    epsgId = getEpsgId(@zone)
    zn = @zone.slice(0, -1)
    proj4.defs(epsgId, "+title=UTM Zone " + @zone + " +proj=utm +zone=" + zn + " +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
    tl = proj4(epsgId, 'WGS84', [@c, @f])
    br = proj4(epsgId, 'WGS84', [@c + @a * @w, @f + @e * @h])
    return [[tl[1], tl[0]], [br[1], br[0]]]

  addToMap: (L, map, opacity=0.7) ->
    return L.imageOverlay(@url, @bounds, { opacity: opacity}).addTo(map)

  @fromLatLngBounds: (url, level, w, h, bounds) ->
    tl = lngLatToUTM([bounds[0][1], bounds[0][0]])
    br = lngLatToUTM([bounds[1][1], bounds[1][0]], tl.zone)
    scale_x = (br.x - tl.x)/w
    scale_y = (br.y - tl.y)/h
    scale = (scale_x - scale_y)/2.0
    return new Overlay(url, level, w, h, scale, tl.zone, tl.x, tl.y)

# "public" - expose to javascript
window.Overlay = Overlay
