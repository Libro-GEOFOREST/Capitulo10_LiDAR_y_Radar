//script path:https://code.earthengine.google.com/?scriptPath=users%2Feavelascop1%2Feavelascop%3ASENTINEL1

// codigo para la obtencion de imagenes SAR (c-band) Sentinel 1

//crea la geometria del area de estudio con las coordenadas, u opcionalmente crea un poligono en la interfaz de GEE denominado geometry y comenta o borra hasta la linea 12

var coordinates = [
   [-3.0093165997753646,37.09212622367329],
   [-2.1551295880566146,37.09212622367329],
   [-2.1551295880566146,37.49417036487973],
   [-3.0093165997753646,37.49417036487973],
   [-3.0093165997753646,37.09212622367329]
   ];

// Crea un objeto ee.Geometry.Polygon
var geometry = ee.Geometry.Polygon(coordinates);

//se puede modificar el periodo de obtencion de las imagenes segun necesidades, en nuestro caso utilizamos meses abril a junio.
// Load the Sentinel-1 ImageCollection, filter to Jun-Sep 2015 observations.

var sentinel1 = ee.ImageCollection('COPERNICUS/S1_GRD')
                    .filterDate('2015-04-01','2015-06-30')
                    .filterBounds(geometry);

// Filter the Sentinel-1 collection by metadata properties.
var vvVhIw = sentinel1
  // Filter to get images with VV and VH dual polarization.
  .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VV'))
  .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VH'))
  // Filter to get images collected in interferometric wide swath mode.
  .filter(ee.Filter.eq('instrumentMode', 'IW'));

// Separate ascending and descending orbit images into distinct collections.
var vvVhIwAsc = vvVhIw.filter(
  ee.Filter.eq('orbitProperties_pass', 'ASCENDING'));
var vvVhIwDesc = vvVhIw.filter(
  ee.Filter.eq('orbitProperties_pass', 'DESCENDING'));

// Calculate temporal means for various observations to use for visualization.
// Mean VH ascending.
var vhIwAscMean = vvVhIwAsc.select('VH').mean();
// Mean VH descending.
var vhIwDescMean = vvVhIwDesc.select('VH').mean();
// Calculate temporal means for various observations to use for visualization.
// Mean VV ascending.
var vvIwAscMean = vvVhIwAsc.select('VV').mean();
// Mean VV descending.
var vvIwDescMean = vvVhIwDesc.select('VV').mean();
// Mean VV for combined ascending and descending image collections.
var vvIwAscDescMean = vvVhIwAsc.merge(vvVhIwDesc).select('VV').mean();
// Mean VH for combined ascending and descending image collections.
var vhIwAscDescMean = vvVhIwAsc.merge(vvVhIwDesc).select('VH').mean();

// Display the temporal means for various observations, compare them.

Map.addLayer(vhIwAscDescMean, {min: -18, max: -10}, 'vhIwAscDescMean');
Map.addLayer(vhIwAscMean, {min: -18, max: -10}, 'vhIwAscMean');
Map.addLayer(vhIwDescMean, {min: -18, max: -10}, 'vhIwDescMean');
Map.addLayer(vvIwAscDescMean, {min: -12, max: -4}, 'vvIwAscDescMean');
Map.addLayer(vvIwAscMean, {min: -18, max: -10}, 'vvIwAscMean');
Map.addLayer(vvIwDescMean, {min: -18, max: -10}, 'vvIwDescMean');

//Aplicamos un filtro para evitar el moteado o "SPECKLE" caracteristico de las imagenes SAR
//Apply filter to reduce speckle
var SMOOTHING_RADIUS = 50;
var vhIwAscDescMean = vhIwAscDescMean.focal_mean(SMOOTHING_RADIUS, 'circle', 'meters');
var vhIwAscMean = vhIwAscMean.focal_mean(SMOOTHING_RADIUS, 'circle', 'meters');
var vhIwDescMean = vhIwDescMean.focal_mean(SMOOTHING_RADIUS, 'circle', 'meters');
var vvIwAscDescMean = vvIwAscDescMean.focal_mean(SMOOTHING_RADIUS, 'circle', 'meters');
var vvIwAscMean = vvIwAscMean.focal_mean(SMOOTHING_RADIUS, 'circle', 'meters');
var vvIwDescMean = vvIwDescMean.focal_mean(SMOOTHING_RADIUS, 'circle', 'meters');


// Export the image, specifying scale and region.
Export.image.toDrive({
  image: vvIwAscMean.select('VV'),
  description: 'vvIwAscMean_2015',
  scale: 10,
  region: geometry,
  maxPixels: 1113892470,
  folder:'S1-2015_spk'
});

// Export the image, specifying scale and region.
Export.image.toDrive({
  image: vvIwDescMean.select('VV'),
  description: 'vvIwDescMean_2015',
  scale: 10,
  region: geometry,
  maxPixels: 1113892470,
  folder:'S1-2015_spk'
});



// Export the image, specifying scale and region.
Export.image.toDrive({
  image: vhIwAscMean.select('VH'),
  description: 'vhIwAscMean_2015',
  scale: 10,
  region: geometry,
  maxPixels: 1113892470,
  folder:'S1-2015_spk'
});

// Export the image, specifying scale and region.
Export.image.toDrive({
  image: vhIwDescMean.select('VH'),
  description: 'vhIwDescMean_2015',
  scale: 10,
  region: geometry,
  maxPixels: 1113892470,
  folder:'S1-2020_spk'
});

// Export the image, specifying scale and region.
Export.image.toDrive({
  image: vvIwAscDescMean.select('VV'),
  description: 'vvIwAscDescMean_2015',
  scale: 10,
  region: geometry,
  maxPixels: 1113892470,
  folder:'S1-2015_spk'
});

// Export the image, specifying scale and region.
Export.image.toDrive({
  image: vhIwAscDescMean.select('VH'),
  description: 'vhIwAscDescMean_2015',
  scale: 10,
  region: geometry,
  maxPixels: 1113892470,
  folder:'S1-2015_spk'
});
