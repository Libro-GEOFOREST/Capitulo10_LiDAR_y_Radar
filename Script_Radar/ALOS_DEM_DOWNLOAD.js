//script path: https://code.earthengine.google.com/?scriptPath=users%2Feavelascop1%2Feavelascop%3Adem
//Descarga ALOS DEM 30M

var coordinates = [
   [-3.0093165997753646,37.09212622367329],
   [-2.1551295880566146,37.09212622367329],
   [-2.1551295880566146,37.49417036487973],
   [-3.0093165997753646,37.49417036487973],
   [-3.0093165997753646,37.09212622367329]
   ];
// Crea un objeto ee.Geometry.Polygon
var geometry = ee.Geometry.Polygon(coordinates);


var elevation = dataset.select('DSM');
var elevation2 = elevation.filterBounds(geometry).mean();
var elevationVis = {
  min: 0,
  max: 5000,
  palette: ['0000ff', '00ffff', 'ffff00', 'ff0000', 'ffffff']
};
Map.setCenter(-4.7227,37.9148,15);
Map.addLayer(elevation2, elevationVis, 'Elevation');
// Reproject an image mosaic using a projection from one of the image tiles,
// rather than using the default projection returned by .mosaic().
var proj = elevation.first().select(0).projection();
var slopeReprojected = ee.Terrain.slope(elevation.mosaic()
                             .setDefaultProjection(proj));
Map.addLayer(slopeReprojected, {min: 0, max: 45}, 'Slope');

Export.image.toDrive({
  image: elevation2,
  description: 'DEM_ALOS',
  scale: 30,
  region: geometry,
  maxPixels: 1113892470,
  folder:'DEM'
});
