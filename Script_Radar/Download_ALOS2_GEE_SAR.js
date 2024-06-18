//script path: https://code.earthengine.google.com/?scriptPath=users%2Feavelascop1%2Feavelascop%3AALOS_2%20Download
// codigo para la obtencion de imagenes SAR (L-band) ALOS PALSAR 2

//crea la geometria del area de estudio con las coordenadas, u opcionalmente crea un poligono en la interfaz de GEE denominado geometry y comenta o borra hasta la linea 15

var coordinates = [
   [-3.0093165997753646,37.09212622367329],
   [-2.1551295880566146,37.09212622367329],
   [-2.1551295880566146,37.49417036487973],
   [-3.0093165997753646,37.49417036487973],
   [-3.0093165997753646,37.09212622367329]
   ];

// Crea un objeto ee.Geometry.Polygon
var geometry = ee.Geometry.Polygon(coordinates);


Map.addLayer(geometry);
Map.centerObject(geometry,11);
var SMOOTHING_RADIUS = 50;

// Cargar ALOS2

//2015

var ALOS2_2015 = ee.ImageCollection("JAXA/ALOS/PALSAR/YEARLY/SAR")
.filter(ee.Filter.date('2015-01-01', '2016-01-01')).mosaic();
var sarHV_2015 = ALOS2_2015.select('HV');
var sarHH_2015 = ALOS2_2015.select('HH');

//Apply filter to reduce speckle

var sarHV_2015_f = sarHV_2015.focal_mean(SMOOTHING_RADIUS, 'circle', 'meters');
var sarHH_2015_f = sarHH_2015.focal_mean(SMOOTHING_RADIUS, 'circle', 'meters');

Map.addLayer(sarHV_2015_f, {color: '006600', strokeWidth: 8}, "HV_2015", true);
Map.addLayer(sarHH_2015_f, {color: '006600', strokeWidth: 8}, "HH_2015", true);

print(sarHV_2015_f);
print(ALOS2_2015);
// Export the image, specifying scale and region.
Export.image.toDrive({
  image: sarHV_2015_f,
  description: 'HV_2015',
  scale: 25,
  region: geometry,
  maxPixels: 1113892470,
  folder:'ALOS_15_SPK'
});

// Export the image, specifying scale and region.
Export.image.toDrive({
  image: sarHH_2015_f,
  description: 'HH_2015',
  scale: 25,
  region: geometry,
  maxPixels: 1113892470,
  folder:'ALOS_15_SPK'
});
