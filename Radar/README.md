
Edward A. Velasco Pereira

# Capítulo 10: Sensores activos en ciencias forestales: Radar

## Modelado de Biomasa (Above Ground Biomass, AGB) con sensores radar SAR y ópticos

#### Cargar las librerías necesarias

```r
pck <- c("tidyr", "dplyr", "readxl", "ggplot2", "randomForest", "car", "Metrics", "raster", "rasterVis", "rgdal", "mapview", "RColorBrewer", "ggplot2", "sf", "glcm", "ggpubr", "sf", "corrplot", "caret", "usdm")
sapply(pck, require, character.only=TRUE)
```

```r annotate
##        tidyr        dplyr       readxl      ggplot2 randomForest          car 
##         TRUE         TRUE         TRUE         TRUE         TRUE         TRUE 
##      Metrics       raster    rasterVis        rgdal      mapview RColorBrewer 
##         TRUE         TRUE         TRUE         TRUE         TRUE         TRUE 
##      ggplot2           sf         glcm       ggpubr           sf     corrplot 
##         TRUE         TRUE         TRUE         TRUE         TRUE         TRUE 
##        caret         usdm 
##         TRUE         TRUE
```

#### ALOS 2

Primero cargaremos las variables SAR ALOS 2, las cuales se descargaron previamente con el código de Google earth engine [https://code.earthengine.google.com/?scriptPath=users%2Feavelascop1%2FCAP_13_RADAR%3AALOS_2%20Download].

El mosaico global PALSAR/PALSAR-2 de 25 m es una imagen SAR global perfecta creada mediante el mosaico de franjas de imágenes SAR de PALSAR/PALSAR-2. para el dataset de GEE Las imágenes SAR se ortorectificaron y se corrigió la pendiente utilizando el modelo de superficie digital ALOS World 3D - 30 m (AW3D30).

Adicional mente en el codigo proporcionado para la descarga del mosaico anual de ALOS 2 se aplico un filtro de de "SPECKLE" para reducir el moteado característico de las imágenes SAR.

```r
getwd()
```

```r annotate
## [1] "D:/cap_Radar"
```

```r
alos2 <- stack(list.files(path="D:/cap_Radar/ALOS_15_SPK",full.names=TRUE))
plot(alos2)
names(alos2)
```

```r annotate
## [1] "HH" "HV"
```

```r
plot(alos2)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/ALOS2.png)

Como los valores de las Imagenes ALOS 2 vienen por efecto con valores de dNúmeros digitales (DN) de 16 bits. Los valores de DN se pueden convertir a valores gamma cero en unidades de decibelios (dB) usando la siguiente ecuación:

```math
\gamma_{0}=10·log_{10}(DN^2) - 83.0 dB
```

```r
alos2_Gamma_dB <- 10 * log10 (alos2^2) - 83.0 
plot(alos2_Gamma_dB )
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/ALOS2b.png)

A continuación, convierta los valores de dB a retrodispersión de potencia aplicando la siguiente ecuación:

```math
\gamma_{pw}=10^(0.1·\gamma_{0})
```

```r
alos2_Gamma_pw <-  10^(0.1*alos2_Gamma_dB)
names(alos2_Gamma_pw)
```

```r annotate
## [1] "HH" "HV"
```

```r
plot(alos2_Gamma_pw)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/ALOS2c.png)

#### Sentinel-1

La misión Sentinel-1 proporciona datos de un instrumento de radar de apertura sintética (SAR) de banda C de doble polarización a 5,405 GHz (banda C). Esta colección incluye las escenas de rango de terreno detectado (GRD) S1, procesadas con Sentinel-1 Toolbox para generar un producto calibrado y ortocorregido. La colección se actualiza diariamente. Los nuevos activos se incorporan dentro de los dos días posteriores a su disponibilidad.

Esta colección contiene todas las escenas de GRD. Cada escena tiene 3 resoluciones (10, 25 o 40 metros), 4 combinaciones de bandas (correspondientes a la polarización de la escena) y 3 modos de instrumento. El uso de la colección en un contexto de mosaico probablemente requerirá filtrar hasta un conjunto homogéneo de bandas y parámetros. Cada escena contiene 1 o 2 de 4 bandas de polarización posibles, dependiendo de la configuración de polarización del instrumento. Las combinaciones posibles son monobanda VV o HH, y doble banda VV+VH y HH+HV:

VV: copolarización única, transmisión vertical/recepción vertical HH: copolarización única, transmisión horizontal/recepción horizontal VV + VH: polarización cruzada de doble banda, transmisión vertical/recepción horizontal HH + HV: polarización cruzada de doble banda, transmisión horizontal/recepción vertical Cada escena también incluye una banda de 'ángulo' adicional que contiene el ángulo de incidencia aproximado desde el elipsoide en grados en cada punto. Esta banda se genera interpolando la propiedad 'incidenceAngle' del campo cuadriculado 'geolocationGridPoint' proporcionado con cada activo.

Cada escena fue preprocesada con Sentinel-1 Toolbox siguiendo los siguientes pasos:

Eliminación de ruido térmico Calibración radiométrica Corrección del terreno utilizando SRTM 30 o ASTER DEM para áreas superiores a 60 grados de latitud, donde SRTM no está disponible. Los valores finales corregidos por el terreno se convierten a decibeles mediante escala logarítmica $`(10·log_{10}(x))`$.

Ahora procederemos a cargar el dataset SAR sentinel 1 que fueron descargados utilizando el script para google earth engine [https://code.earthengine.google.com/?scriptPath=users%2Feavelascop1%2FCAP_13_RADAR%3ASENTINEL1], como en el script de Alos2 tambien fue aplicado un filtro de Speckle.


```r
S1_2015 <- stack(list.files(path="D:/cap_Radar/S1_2015_SPK",full.names=TRUE))

names(S1_2015) <- c("vhAscDesc_2015", "vhAsc_2015","vhDesc_2015" ,"vvAscDesc_2015", "vvAsc_2015","vvDesc_2015")


#resampleamos al tamaño de pixel de las imagenes ALOS2
S1_2015 <- resample(S1_2015, alos2_Gamma_pw)

plot(S1_2015)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/ALOS2d.png)

Los datos del dataset de sentinel 1 de GEE vienen en valores de DB, por lo que para comvertirlos en valores de Gamma PW debemos utilizar la formula usada anteriormente con los datos de Alos-2.

```r
S1_2015_Gamma_pw <-  10^(0.1*S1_2015)

plot(S1_2015_Gamma_pw)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/ALOS2f.png)

```r
names_S1_2015 <- names(S1_2015_Gamma_pw)
```

#### Landsat 8

##### Carga indices Landsat

Los datos SAR funcionan mejor cuando se combinan con otro tipo de sensores ópticos como lidar o imágenes ópticas satelitales, en nuestro caso de estudio utilizaremos datos opticos ya que las colecciones son libres y tienen cobertura mundial, por lo que a continuación haremos la carga de los indices satelitales landsat 8 calculados previamente en el codigo de google earth engine: [https://code.earthengine.google.com/?scriptPath=users%2Feavelascop1%2FCAP_13_RADAR%3AINDEX_L8]

```r
LANDSAT <- stack(list.files(path="D:/cap_Radar/LANDSAT_2015",full.names=TRUE))

LANDSAT <- resample(LANDSAT, alos2_Gamma_pw)

plot(LANDSAT)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/Landsat.png)

Cargamos los datos de las parcelas de campo, las cuales se encuentra en un shp denominado inventario_biomasawgs84.shp

```r
getwd()
```

```r annotate
## [1] "D:/cap_Radar"
```

```r
parcelas <- st_read("D:/cap_Radar/inventario_biomasa_wgs84/inventario_biomasa_wgs84.shp")
```

```r annotate
## Reading layer `inventario_biomasa_wgs84' from data source 
##   `D:\cap_13_Radar\inventario_biomasa_wgs84\inventario_biomasa_wgs84.shp' 
##   using driver `ESRI Shapefile'
## Warning in CPL_read_ogr(dsn, layer, query, as.character(options), quiet, : GDAL
## Error 1: PROJ: proj_identify: C:\Program
## Files\PostgreSQL\14\share\contrib\postgis-3.1\proj\proj.db lacks
## DATABASE.LAYOUT.VERSION.MAJOR / DATABASE.LAYOUT.VERSION.MINOR metadata. It
## comes from another PROJ installation.
## Simple feature collection with 2107 features and 11 fields
## Geometry type: POINT
## Dimension:     XY
## Bounding box:  xmin: -2.865975 ymin: 37.14839 xmax: -2.193143 ymax: 37.35033
## Geodetic CRS:  WGS 84
```

```r
plot(parcelas[3])
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/Parcelas2.png)

```r
names(parcelas)
```

```r annotate
##  [1] "FID"      "OBJECTI"  "N_Cintf"  "Dnm_cm"   "Npies_h"  "AB_m2_h" 
##  [7] "Dmc_cm"   "Ho_m"     "Bttl_Kg"  "MgC.pr_"  "Ctt_MC."  "geometry"
```

Revisamos y limpiamos los datos de las parcelas

```r
# Estudio previo de los datos
# Se carga la librería 'car' para usar algunas funciones útiles.
library(car)

# Se imprime un resumen estadístico de la variable 'Ctt_MC.' en el dataframe 'parcelas'.
summary(parcelas$Ctt_MC.)
```

```r annotate
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##    0.00   11.18   29.09   37.76   57.55  331.41
```

```r
# Se crea un diagrama de caja (boxplot) para visualizar la distribución de la variable 'Ctt_MC.' en 'parcelas'.
Boxplot(parcelas$Ctt_MC.)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/boxplot2.png)

```r annotate
##  [1]  779  838  847  996 1752 1073 1278 1617 1031 1213
```

```r
# Se identifican los valores atípicos (outliers) de la variable 'Ctt_MC.' utilizando boxplot.
outliners <- boxplot(parcelas$Ctt_MC.)$out
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/boxplot3.png)

```r
outliners
```

```r annotate
##  [1] 331.4067 250.3730 196.3495 130.4630 127.2519 127.9674 131.3214 128.0279
##  [9] 149.0483 132.7146 138.2332 132.4152 135.2561 128.2277 129.4878 134.6589
## [17] 141.0414
```

```r
# Se filtran los datos para mantener solo aquellos cuyo valor en 'Ctt_MC.' sea menor o igual a 127.2519.
parcelas <- subset.data.frame(parcelas, parcelas$Ctt_MC. <= 120 )

# Se imprime un resumen estadístico de 'Ctt_MC.' después de filtrar los valores.
summary(parcelas$Ctt_MC.)
```

```r annotate
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##    0.00   11.05   28.55   36.42   55.87  119.38
```

```r
# Se crea un nuevo boxplot para visualizar la distribución actualizada de 'Ctt_MC.'.
Boxplot(parcelas$Ctt_MC.)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/boxplot4.png)

```r
# Se imprime un resumen estadístico adicional de 'Ctt_MC.' después del filtrado.
summary(parcelas$Ctt_MC.)
```

```r annotate
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##    0.00   11.05   28.55   36.42   55.87  119.38
```

```r
# Se crea un histograma para visualizar la distribución de 'Ctt_MC.' después del filtrado.
hist(parcelas$Ctt_MC.)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/histograma2.png)

```r
# Se identifican los índices de las observaciones cuyo valor en 'Ctt_MC.' es igual a cero.
which(parcelas$Ctt_MC. == 0)
```

```r annotate
## [1] 696 786 792 820 828
```

```r
# Se eliminan las observaciones donde 'Ctt_MC.' es igual a cero del dataframe 'parcelas'.
parcelas <- parcelas[-which(parcelas$Ctt_MC. == 0),]

# Se crea otro histograma para visualizar la distribución de 'Ctt_MC.' después de eliminar los valores iguales a cero.
hist(parcelas$Ctt_MC.)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/histograma3.png)

#### Dem Alos world 3d

Ahora vamos a cargar el DEM derivado del la colección ALOS World 3D - 30m (AW3D30), la cual es un conjunto de datos de modelo de superficie digital (DSM) global con una resolución horizontal de aproximadamente 30 metros (malla de 1 arco segundo).

El script de descarga de GEE se encuentra en: [https://code.earthengine.google.com/?scriptPath=users%2Feavelascop1%2FCAP_13_RADAR%3AALOS_DEM]

```r
# Cargar el DEM
DEM <- raster("D:/cap_13_Radar/DEM/DEM_ALOS.tif")
# Mostrar el mapa de aspecto
plot(DEM , main = "MAPA DE ELEVACIONES DEM")
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/DEM.png)

```r
# Calcular el aspect
ASPECT <- terrain(DEM, opt = "aspect")

# Mostrar el mapa de aspecto
plot(ASPECT, main = "Mapa de Aspecto")
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/Aspect.png)

```r
# Calcular la pendiente
SLOPE <- terrain(DEM, opt = "slope")

# Mostrar el mapa de pendiente
plot(SLOPE, main = "Mapa de Pendiente")
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/Pendiente2.png)

```r
TOPO <- stack(DEM, SLOPE, ASPECT)

TOPO <- resample(TOPO, alos2_Gamma_pw)
plot(TOPO)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/TOPO.png)

```r
names(TOPO) <-  c("DEM", "SLOPE", "ASPECT")
```

Cargamos los polígonos de la delimitacion de los pinares en filabres por especie

```r
pinus <- rgdal::readOGR("D:/cap_Radar/inventario_biomasa_wgs84/pinos_filabres_wgs_84.shp")

# Cargar la librería sf
library(sf)

# Filtrar por especie "PH"
pinus_PH <- pinus[pinus$ESPECIE == "PH", ]
pinus_PP <- pinus[pinus$ESPECIE == "PT", ]
```

Extraemos los puntos de coincidencia entre las parcelas y los rasters preparados anteriormente

```r
#stack final de los set ya preparados
rasters1 <- stack(alos2_Gamma_pw, S1_2015_Gamma_pw,LANDSAT, TOPO)

plot(rasters1)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/stack.png)

```r
#hacemos el extract con un buffer de 50 metros para minimizar los posibles errores de proyección de coordenadas 
rasters1_extract <- raster::extract(rasters1,parcelas, buffer=50, fun=mean)

#extraemos los puntos
MALLA_SAR_50<-cbind(parcelas,rasters1_extract)

write.csv(MALLA_SAR_50, "MALLA_SAR_50.csv")

plot(MALLA_SAR_50, max.plot = 50)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/extract.png)

```r
names(MALLA_SAR_50)
```

```r annotate
##  [1] "FID"            "OBJECTI"        "N_Cintf"        "Dnm_cm"        
##  [5] "Npies_h"        "AB_m2_h"        "Dmc_cm"         "Ho_m"          
##  [9] "Bttl_Kg"        "MgC.pr_"        "Ctt_MC."        "HH"            
## [13] "HV"             "vhAscDesc_2015" "vhAsc_2015"     "vhDesc_2015"   
## [17] "vvAscDesc_2015" "vvAsc_2015"     "vvDesc_2015"    "SR_B2"         
## [21] "brightness"     "DVI"            "EVI"            "GNDVI"         
## [25] "SR_B3"          "greenness"      "GVI"            "LAI"           
## [29] "NBR"            "NDBI"           "NDVI"           "SR_B5"         
## [33] "NLI"            "NRVI"           "OSAVI"          "RDVI"          
## [37] "SR_B4"          "RVI"            "SAVI"           "SR_B6"         
## [41] "SR_B7"          "SLAVI"          "TVI"            "wetness"       
## [45] "DEM"            "SLOPE"          "ASPECT"         "geometry"
```

```r
ds <- as.data.frame(MALLA_SAR_50)
ds <- ds[-48] 

#filtramos el dataset a nuestras especies de interés
DS_PH <- filter(ds, N_Cintf == "Pinus halepensis") 
DS_PP <- filter(ds, N_Cintf == "Pinus pinaster")

### Calcular VIF basandonos en las funciones vifcor y vifstep
#############################################################
var.df <- as.data.frame(rasters1)
 
v.1 <-vifcor(var.df , th=0.8) # Busca un par de variables que tengan la maxima correlacion lineal (mayor que th) y excluye una de ellas que tenga mayor VIF. El procedimiento se repite hasta que no quede ninguna variable con alto coeficiente de correlacion (mayor que el umbral) con otras variables

v.1
```

```r annotate 
## 23 variables from the 36 input variables have collinearity problem: 
##  
## NDBI LAI SAVI NDVI SLAVI OSAVI TVI GNDVI NLI RVI SR_B6 RDVI SR_B4 SR_B3 brightness DVI greenness vhAsc_2015 vhDesc_2015 GVI SR_B7 vvAscDesc_2015 NBR 
## 
## After excluding the collinear variables, the linear correlation coefficients ranges between: 
## min correlation ( EVI ~ vvDesc_2015 ):  0.005486148 
## max correlation ( SR_B5 ~ SR_B2 ):  0.7821688 
## 
## ---------- VIFs of the remained variables -------- 
##         Variables      VIF
## 1              HH 1.933619
## 2              HV 3.571693
## 3  vhAscDesc_2015 2.523411
## 4      vvAsc_2015 1.896266
## 5     vvDesc_2015 1.882706
## 6           SR_B2 8.068110
## 7             EVI 1.027423
## 8           SR_B5 8.231925
## 9            NRVI 4.626137
## 10        wetness 2.332853
## 11            DEM 1.536606
## 12          SLOPE 1.937004
## 13         ASPECT 1.262707
```

```r 
v.2 <- vifstep(var.df, th=7) # Calcula el VIF para todas las variables, excluye una con el VIF mas alto (mayor que el umbral), repite el procedimiento hasta que no quede ninguna variable con VIF mayor que th.
v.2
```

```r annotate 
## 24 variables from the 36 input variables have collinearity problem: 
##  
## NBR EVI SAVI NDVI greenness SR_B4 SR_B6 SLAVI TVI OSAVI brightness RDVI NLI GNDVI SR_B5 SR_B3 RVI NRVI wetness vhAscDesc_2015 GVI SR_B7 vhDesc_2015 vhAsc_2015 
## 
## After excluding the collinear variables, the linear correlation coefficients ranges between: 
## min correlation ( LAI ~ vvAsc_2015 ):  0.001304587 
## max correlation ( HV ~ HH ):  0.7404837 
## 
## ---------- VIFs of the remained variables -------- 
##         Variables      VIF
## 1              HH 2.524338
## 2              HV 4.298979
## 3  vvAscDesc_2015 2.840767
## 4      vvAsc_2015 2.500726
## 5     vvDesc_2015 2.706190
## 6           SR_B2 1.502365
## 7             DVI 2.391994
## 8             LAI 1.004059
## 9            NDBI 2.767276
## 10            DEM 1.584902
## 11          SLOPE 1.622565
## 12         ASPECT 1.273745
```

```r 
re1 <- exclude(rasters1,v.2)
re1
```

```r annotate 
## class      : RasterStack 
## dimensions : 1794, 3804, 6824376, 12  (nrow, ncol, ncell, nlayers)
## resolution : 0.0002245788, 0.0002245788  (x, y)
## extent     : -3.009356, -2.155058, 37.09211, 37.49501  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## names      :            HH,            HV, vvAscDesc_2015,    vvAsc_2015,   vvDesc_2015,         SR_B2,           DVI,           LAI,          NDBI,           DEM,         SLOPE,        ASPECT 
## min values :  2.432126e-03,  2.669044e-04,   1.276776e-02,  8.352074e-03,  7.183256e-03,  4.916208e+03, -1.608826e+03, -1.607692e+04, -4.465110e-01,  3.307917e+02,  0.000000e+00,  0.000000e+00 
## max values :  1.159834e+01,  1.705286e+00,   1.262230e+01,  1.772115e+01,  9.253421e+01,  2.698925e+04,  1.862317e+04,  1.346486e+04,  1.724137e-01,  2.605000e+03,  1.141819e+00,  6.283185e+00
```

```r 
names(re1)
```

```r annotate 
##  [1] "HH"             "HV"             "vvAscDesc_2015" "vvAsc_2015"    
##  [5] "vvDesc_2015"    "SR_B2"          "DVI"            "LAI"           
##  [9] "NDBI"           "DEM"            "SLOPE"          "ASPECT"
```

```r 
plot(re1)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/RE1.png)

Ahora dividiremos el set de datos en 80% de datos para entrenamiento y 20% para testeo para los dos datasets de *Pinus pinaster* y *Pinus halepensis*.

```r 
# Dividir los datos en un conjunto de entrenamiento (80%) y un conjunto de prueba 20%) para PH
set.seed(123)
train_index <- createDataPartition(y =DS_PH$Ctt_MC., p = 0.8, list = FALSE)
train_PH <-DS_PH[train_index, ]
test_PH <-DS_PH[-train_index, ]

summary(train_PH)
```

```r annotate 
##       FID            OBJECTI        N_Cintf              Dnm_cm     
##  Min.   :  21.0   Min.   : 3010   Length:506         Min.   :10.61  
##  1st Qu.: 943.2   1st Qu.: 3950   Class :character   1st Qu.:13.72  
##  Median :1668.5   Median : 4676   Mode  :character   Median :15.32  
##  Mean   :1465.2   Mean   : 8160                      Mean   :17.30  
##  3rd Qu.:1864.8   3rd Qu.: 4872                      3rd Qu.:19.17  
##  Max.   :2839.0   Max.   :46696                      Max.   :58.37  
##     Npies_h            AB_m2_h            Dmc_cm           Ho_m       
##  Min.   :   5.093   Min.   : 0.1772   Min.   :10.61   Min.   : 3.546  
##  1st Qu.: 220.547   1st Qu.: 4.0819   1st Qu.:13.88   1st Qu.: 6.851  
##  Median : 380.945   Median : 7.1103   Median :15.63   Median : 7.922  
##  Mean   : 416.825   Mean   :10.1075   Mean   :17.60   Mean   : 9.116  
##  3rd Qu.: 541.343   3rd Qu.:14.4820   3rd Qu.:19.69   3rd Qu.:11.005  
##  Max.   :2260.002   Max.   :42.5279   Max.   :60.07   Max.   :27.484  
##     Bttl_Kg          MgC.pr_           Ctt_MC.              HH        
##  Min.   : 129.3   Min.   :0.01264   Min.   : 0.2534   Min.   :0.0159  
##  1st Qu.: 224.1   1st Qu.:0.33477   1st Qu.: 6.7123   1st Qu.:0.1125  
##  Median : 338.5   Median :0.60418   Median :12.1139   Median :0.1505  
##  Mean   : 528.2   Mean   :0.98720   Mean   :19.7935   Mean   :0.1703  
##  3rd Qu.: 661.4   3rd Qu.:1.37863   3rd Qu.:27.6418   3rd Qu.:0.2040  
##  Max.   :5540.8   Max.   :4.89050   Max.   :98.0551   Max.   :1.0534  
##        HV           vhAscDesc_2015      vhAsc_2015       vhDesc_2015     
##  Min.   :0.002783   Min.   :0.01934   Min.   :0.01458   Min.   :0.01288  
##  1st Qu.:0.030234   1st Qu.:0.02974   1st Qu.:0.02650   1st Qu.:0.02473  
##  Median :0.042002   Median :0.03321   Median :0.03261   Median :0.03209  
##  Mean   :0.043745   Mean   :0.03407   Mean   :0.03742   Mean   :0.03612  
##  3rd Qu.:0.055124   3rd Qu.:0.03727   3rd Qu.:0.04172   3rd Qu.:0.04282  
##  Max.   :0.118287   Max.   :0.06863   Max.   :0.20586   Max.   :0.15697  
##  vvAscDesc_2015      vvAsc_2015       vvDesc_2015          SR_B2      
##  Min.   :0.08023   Min.   :0.04893   Min.   :0.04136   Min.   : 8037  
##  1st Qu.:0.11088   1st Qu.:0.09140   1st Qu.:0.08664   1st Qu.: 8801  
##  Median :0.12287   Median :0.11742   Median :0.11746   Median : 9135  
##  Mean   :0.13052   Mean   :0.15415   Mean   :0.15015   Mean   : 9302  
##  3rd Qu.:0.14157   3rd Qu.:0.16581   3rd Qu.:0.17863   3rd Qu.: 9473  
##  Max.   :0.34069   Max.   :0.93978   Max.   :0.82425   Max.   :15317  
##    brightness         DVI            EVI                GNDVI        
##  Min.   :22785   Min.   :1853   Min.   :-191.8228   Min.   :0.08287  
##  1st Qu.:25912   1st Qu.:2813   1st Qu.:   0.8833   1st Qu.:0.13523  
##  Median :27103   Median :3123   Median :   1.2357   Median :0.14680  
##  Mean   :27411   Mean   :3164   Mean   :   0.8794   Mean   :0.14790  
##  3rd Qu.:28511   3rd Qu.:3455   3rd Qu.:   1.6432   3rd Qu.:0.15873  
##  Max.   :39037   Max.   :5209   Max.   :  11.1121   Max.   :0.22350  
##      SR_B3         greenness            GVI              LAI          
##  Min.   : 8699   Min.   :-4737.9   Min.   :0.6350   Min.   :-610.115  
##  1st Qu.: 9666   1st Qu.:-2141.6   1st Qu.:0.7265   1st Qu.:   2.691  
##  Median :10056   Median :-1821.8   Median :0.7443   Median :   3.812  
##  Mean   :10245   Mean   :-1845.2   Mean   :0.7434   Mean   :   2.679  
##  3rd Qu.:10565   3rd Qu.:-1479.9   3rd Qu.:0.7625   3rd Qu.:   5.107  
##  Max.   :16042   Max.   :  122.5   Max.   :0.8524   Max.   :  35.218  
##       NBR               NDBI               NDVI             SR_B5      
##  Min.   :0.02610   Min.   :-0.19843   Min.   :0.07217   Min.   :11397  
##  1st Qu.:0.07436   1st Qu.:-0.10663   1st Qu.:0.11658   1st Qu.:13050  
##  Median :0.08884   Median :-0.08884   Median :0.13068   Median :13646  
##  Mean   :0.09088   Mean   :-0.09088   Mean   :0.13253   Mean   :13760  
##  3rd Qu.:0.10663   3rd Qu.:-0.07436   3rd Qu.:0.14603   3rd Qu.:14290  
##  Max.   :0.19843   Max.   :-0.02610   Max.   :0.22641   Max.   :18904  
##       NLI              NRVI            OSAVI             RDVI      
##  Min.   :0.0722   Min.   :0.4120   Min.   :0.1083   Min.   :11.46  
##  1st Qu.:0.1166   1st Qu.:0.6576   1st Qu.:0.1749   1st Qu.:18.14  
##  Median :0.1307   Median :0.6983   Median :0.1960   Median :20.24  
##  Mean   :0.1325   Mean   :0.6915   Mean   :0.1988   Mean   :20.45  
##  3rd Qu.:0.1460   3rd Qu.:0.7351   3rd Qu.:0.2190   3rd Qu.:22.29  
##  Max.   :0.2264   Max.   :0.8372   Max.   :0.3396   Max.   :34.34  
##      SR_B4            RVI              SAVI            SR_B6      
##  Min.   : 8621   Min.   :0.6315   Min.   :0.1083   Min.   :10492  
##  1st Qu.: 9918   1st Qu.:0.7453   1st Qu.:0.1749   1st Qu.:12621  
##  Median :10417   Median :0.7695   Median :0.1960   Median :13467  
##  Mean   :10596   Mean   :0.7673   Mean   :0.1988   Mean   :13519  
##  3rd Qu.:11077   3rd Qu.:0.7917   3rd Qu.:0.2190   3rd Qu.:14400  
##  Max.   :16451   Max.   :0.8700   Max.   :0.3396   Max.   :17833  
##      SR_B7           SLAVI             TVI            wetness     
##  Min.   : 9095   Min.   :0.5361   Min.   :0.7556   Min.   :-5648  
##  1st Qu.:10744   1st Qu.:0.5583   1st Qu.:0.7852   1st Qu.:-3697  
##  Median :11422   Median :0.5653   Median :0.7940   Median :-3209  
##  Mean   :11496   Mean   :0.5663   Mean   :0.7951   Mean   :-3269  
##  3rd Qu.:12181   3rd Qu.:0.5730   3rd Qu.:0.8037   3rd Qu.:-2762  
##  Max.   :14992   Max.   :0.6132   Max.   :0.8522   Max.   :-1126  
##       DEM             SLOPE             ASPECT      
##  Min.   : 502.5   Min.   :0.04791   Min.   :0.3384  
##  1st Qu.: 682.3   1st Qu.:0.24013   1st Qu.:1.6807  
##  Median : 888.4   Median :0.30851   Median :2.8795  
##  Mean   : 934.3   Mean   :0.31211   Mean   :2.9892  
##  3rd Qu.:1209.3   3rd Qu.:0.37499   3rd Qu.:4.2867  
##  Max.   :1860.2   Max.   :0.67233   Max.   :6.0826
```

```r 
summary(test_PH)
```

```r annotate 
##       FID          OBJECTI        N_Cintf              Dnm_cm     
##  Min.   :  19   Min.   : 3024   Length:124         Min.   :10.59  
##  1st Qu.:1095   1st Qu.: 4102   Class :character   1st Qu.:13.48  
##  Median :1662   Median : 4669   Mode  :character   Median :15.39  
##  Mean   :1466   Mean   : 7100                      Mean   :17.22  
##  3rd Qu.:1834   3rd Qu.: 4840                      3rd Qu.:20.02  
##  Max.   :2830   Max.   :46678                      Max.   :37.25  
##     Npies_h           AB_m2_h            Dmc_cm           Ho_m       
##  Min.   :  20.05   Min.   : 0.1766   Min.   :10.59   Min.   : 3.540  
##  1st Qu.: 240.60   1st Qu.: 4.3174   1st Qu.:13.56   1st Qu.: 6.803  
##  Median : 380.95   Median : 7.2154   Median :15.70   Median : 7.832  
##  Mean   : 429.48   Mean   :10.5365   Mean   :17.46   Mean   : 8.915  
##  3rd Qu.: 541.34   3rd Qu.:14.4403   3rd Qu.:20.52   3rd Qu.:10.945  
##  Max.   :1303.23   Max.   :42.1995   Max.   :37.25   Max.   :15.788  
##     Bttl_Kg          MgC.pr_          Ctt_MC.              HH        
##  Min.   : 131.6   Min.   :0.0126   Min.   : 0.2527   Min.   :0.0279  
##  1st Qu.: 221.3   1st Qu.:0.3353   1st Qu.: 6.7231   1st Qu.:0.1146  
##  Median : 325.4   Median :0.6031   Median :12.0924   Median :0.1608  
##  Mean   : 487.2   Mean   :1.0220   Mean   :20.4917   Mean   :0.1678  
##  3rd Qu.: 647.2   3rd Qu.:1.3774   3rd Qu.:27.6164   3rd Qu.:0.2005  
##  Max.   :2294.8   Max.   :4.4170   Max.   :88.5609   Max.   :0.6073  
##        HV           vhAscDesc_2015      vhAsc_2015       vhDesc_2015     
##  Min.   :0.005694   Min.   :0.02196   Min.   :0.01304   Min.   :0.01436  
##  1st Qu.:0.029249   1st Qu.:0.03081   1st Qu.:0.02640   1st Qu.:0.02480  
##  Median :0.044233   Median :0.03326   Median :0.03237   Median :0.03324  
##  Mean   :0.045533   Mean   :0.03461   Mean   :0.03885   Mean   :0.03675  
##  3rd Qu.:0.060632   3rd Qu.:0.03714   3rd Qu.:0.04293   3rd Qu.:0.04212  
##  Max.   :0.118746   Max.   :0.05848   Max.   :0.11844   Max.   :0.14526  
##  vvAscDesc_2015      vvAsc_2015       vvDesc_2015          SR_B2      
##  Min.   :0.08491   Min.   :0.04756   Min.   :0.04328   Min.   : 8031  
##  1st Qu.:0.10966   1st Qu.:0.08980   1st Qu.:0.08487   1st Qu.: 8677  
##  Median :0.12232   Median :0.12272   Median :0.12038   Median : 9017  
##  Mean   :0.13174   Mean   :0.16257   Mean   :0.15160   Mean   : 9217  
##  3rd Qu.:0.13799   3rd Qu.:0.16565   3rd Qu.:0.17280   3rd Qu.: 9505  
##  Max.   :0.34326   Max.   :0.97181   Max.   :0.78906   Max.   :14259  
##    brightness         DVI            EVI               GNDVI       
##  Min.   :22467   Min.   :2090   Min.   :-39.8404   Min.   :0.1064  
##  1st Qu.:25578   1st Qu.:2872   1st Qu.:  0.8391   1st Qu.:0.1349  
##  Median :26614   Median :3105   Median :  1.3940   Median :0.1468  
##  Mean   :27190   Mean   :3182   Mean   :  0.9492   Mean   :0.1483  
##  3rd Qu.:28611   3rd Qu.:3472   3rd Qu.:  1.7009   3rd Qu.:0.1601  
##  Max.   :36922   Max.   :4838   Max.   :  4.5486   Max.   :0.2060  
##      SR_B3         greenness            GVI              LAI          
##  Min.   : 8717   Min.   :-4320.8   Min.   :0.6584   Min.   :-126.810  
##  1st Qu.: 9548   1st Qu.:-2201.5   1st Qu.:0.7241   1st Qu.:   2.550  
##  Median : 9918   Median :-1788.2   Median :0.7442   Median :   4.315  
##  Mean   :10158   Mean   :-1799.3   Mean   :0.7427   Mean   :   2.900  
##  3rd Qu.:10679   3rd Qu.:-1458.7   3rd Qu.:0.7626   3rd Qu.:   5.291  
##  Max.   :14570   Max.   : -408.6   Max.   :0.8106   Max.   :  14.347  
##       NBR               NDBI               NDVI             SR_B5      
##  Min.   :0.02585   Min.   :-0.15145   Min.   :0.07982   Min.   :11292  
##  1st Qu.:0.07343   1st Qu.:-0.10852   1st Qu.:0.11677   1st Qu.:12869  
##  Median :0.09226   Median :-0.09226   Median :0.13194   Median :13479  
##  Mean   :0.09179   Mean   :-0.09179   Mean   :0.13416   Mean   :13664  
##  3rd Qu.:0.10852   3rd Qu.:-0.07343   3rd Qu.:0.14789   3rd Qu.:14215  
##  Max.   :0.15145   Max.   :-0.02585   Max.   :0.19602   Max.   :17850  
##       NLI               NRVI            OSAVI             RDVI      
##  Min.   :0.07984   Min.   :0.5114   Min.   :0.1197   Min.   :13.01  
##  1st Qu.:0.11677   1st Qu.:0.6523   1st Qu.:0.1752   1st Qu.:18.44  
##  Median :0.13195   Median :0.6954   Median :0.1979   Median :20.03  
##  Mean   :0.13416   Mean   :0.6870   Mean   :0.2012   Mean   :20.63  
##  3rd Qu.:0.14790   3rd Qu.:0.7341   3rd Qu.:0.2218   3rd Qu.:22.50  
##  Max.   :0.19600   Max.   :0.8257   Max.   :0.2940   Max.   :30.44  
##      SR_B4            RVI              SAVI            SR_B6      
##  Min.   : 8625   Min.   :0.6725   Min.   :0.1197   Min.   :10501  
##  1st Qu.: 9760   1st Qu.:0.7426   1st Qu.:0.1752   1st Qu.:12489  
##  Median :10257   Median :0.7671   Median :0.1979   Median :13123  
##  Mean   :10482   Mean   :0.7648   Mean   :0.2012   Mean   :13428  
##  3rd Qu.:11163   3rd Qu.:0.7919   3rd Qu.:0.2218   3rd Qu.:14372  
##  Max.   :14774   Max.   :0.8527   Max.   :0.2940   Max.   :18685  
##      SR_B7           SLAVI             TVI            wetness     
##  Min.   : 9161   Min.   :0.5399   Min.   :0.7614   Min.   :-5812  
##  1st Qu.:10638   1st Qu.:0.5584   1st Qu.:0.7852   1st Qu.:-3659  
##  Median :11186   Median :0.5660   Median :0.7949   Median :-3149  
##  Mean   :11405   Mean   :0.5671   Mean   :0.7961   Mean   :-3263  
##  3rd Qu.:12131   3rd Qu.:0.5739   3rd Qu.:0.8049   3rd Qu.:-2769  
##  Max.   :15743   Max.   :0.5980   Max.   :0.8342   Max.   :-1398  
##       DEM             SLOPE            ASPECT     
##  Min.   : 527.1   Min.   :0.1030   Min.   :0.551  
##  1st Qu.: 685.4   1st Qu.:0.2574   1st Qu.:1.731  
##  Median : 809.7   Median :0.3325   Median :2.866  
##  Mean   : 916.5   Mean   :0.3316   Mean   :3.062  
##  3rd Qu.:1164.1   3rd Qu.:0.3977   3rd Qu.:4.415  
##  Max.   :1397.4   Max.   :0.5722   Max.   :5.906
```

```r 
# Dividir los datos en un conjunto de entrenamiento (70%) y un conjunto de prueba (30%)
set.seed(123)
train_index <- createDataPartition(y =DS_PP$Ctt_MC., p = 0.8, list = FALSE)
train_PP <-DS_PP[train_index, ]
test_PP <-DS_PP[-train_index, ]

summary(train_PP)
```


```r annotate 
##       FID            OBJECTI        N_Cintf              Dnm_cm     
##  Min.   :   8.0   Min.   : 3007   Length:575         Min.   :12.32  
##  1st Qu.: 689.5   1st Qu.: 3696   Class :character   1st Qu.:19.74  
##  Median :1245.0   Median : 4252   Mode  :character   Median :23.46  
##  Mean   :1231.3   Mean   : 7339                      Mean   :23.40  
##  3rd Qu.:1556.5   3rd Qu.: 4564                      3rd Qu.:26.68  
##  Max.   :2829.0   Max.   :46677                      Max.   :58.22  
##     Npies_h           AB_m2_h            Dmc_cm           Ho_m       
##  Min.   :  14.15   Min.   : 0.3187   Min.   :12.42   Min.   : 5.457  
##  1st Qu.: 252.34   1st Qu.: 9.6089   1st Qu.:20.03   1st Qu.: 9.792  
##  Median : 501.24   Median :21.2109   Median :23.79   Median :11.429  
##  Mean   : 532.77   Mean   :23.6669   Mean   :23.74   Mean   :11.296  
##  3rd Qu.: 761.89   3rd Qu.:35.8138   3rd Qu.:27.05   3rd Qu.:12.794  
##  Max.   :1784.43   Max.   :66.9574   Max.   :58.23   Max.   :21.330  
##     Bttl_Kg           MgC.pr_           Ctt_MC.               HH         
##  Min.   :  27.29   Min.   :0.01862   Min.   :  0.3734   Min.   :0.02432  
##  1st Qu.: 353.15   1st Qu.:0.77723   1st Qu.: 15.5836   1st Qu.:0.13050  
##  Median : 563.79   Median :1.89458   Median : 37.9866   Median :0.17496  
##  Mean   : 684.88   Mean   :2.13374   Mean   : 42.7818   Mean   :0.18461  
##  3rd Qu.: 937.98   3rd Qu.:3.27723   3rd Qu.: 65.7088   3rd Qu.:0.22455  
##  Max.   :3744.09   Max.   :5.71134   Max.   :114.5130   Max.   :1.03525  
##        HV           vhAscDesc_2015      vhAsc_2015        vhDesc_2015     
##  Min.   :0.004446   Min.   :0.01754   Min.   :0.009292   Min.   :0.01017  
##  1st Qu.:0.033228   1st Qu.:0.02615   1st Qu.:0.021690   1st Qu.:0.01997  
##  Median :0.050045   Median :0.02902   Median :0.027518   Median :0.02705  
##  Mean   :0.051441   Mean   :0.02934   Mean   :0.033008   Mean   :0.03107  
##  3rd Qu.:0.067803   3rd Qu.:0.03211   3rd Qu.:0.040275   3rd Qu.:0.03888  
##  Max.   :0.152579   Max.   :0.06309   Max.   :0.125276   Max.   :0.10816  
##  vvAscDesc_2015      vvAsc_2015       vvDesc_2015          SR_B2      
##  Min.   :0.07440   Min.   :0.03534   Min.   :0.03114   Min.   : 7925  
##  1st Qu.:0.09466   1st Qu.:0.07204   1st Qu.:0.06728   1st Qu.: 8393  
##  Median :0.10690   Median :0.09711   Median :0.10055   Median : 8790  
##  Mean   :0.11324   Mean   :0.14376   Mean   :0.13354   Mean   : 9161  
##  3rd Qu.:0.12368   3rd Qu.:0.16553   3rd Qu.:0.15615   3rd Qu.: 9311  
##  Max.   :0.31366   Max.   :2.86281   Max.   :0.99251   Max.   :17183  
##    brightness         DVI            EVI               GNDVI       
##  Min.   :22467   Min.   :1799   Min.   :-75.0934   Min.   :0.1054  
##  1st Qu.:25457   1st Qu.:3517   1st Qu.:  0.9531   1st Qu.:0.1619  
##  Median :26799   Median :4345   Median :  1.3764   Median :0.1939  
##  Mean   :27646   Mean   :4334   Mean   :  1.1835   Mean   :0.1917  
##  3rd Qu.:28676   3rd Qu.:5133   3rd Qu.:  1.9397   3rd Qu.:0.2223  
##  Max.   :45167   Max.   :6422   Max.   : 11.6576   Max.   :0.2603  
##      SR_B3         greenness             GVI              LAI          
##  Min.   : 8530   Min.   :-5204.90   Min.   :0.5870   Min.   :-238.915  
##  1st Qu.: 9194   1st Qu.:-1698.64   1st Qu.:0.6366   1st Qu.:   2.913  
##  Median : 9723   Median : -833.85   Median :0.6759   Median :   4.259  
##  Mean   :10110   Mean   : -925.58   Mean   :0.6807   Mean   :   3.645  
##  3rd Qu.:10469   3rd Qu.:   17.42   3rd Qu.:0.7223   3rd Qu.:   6.050  
##  Max.   :17903   Max.   : 1000.74   Max.   :0.8097   Max.   :  36.953  
##       NBR               NDBI               NDVI             SR_B5      
##  Min.   :0.04092   Min.   :-0.24051   Min.   :0.07198   Min.   :11292  
##  1st Qu.:0.10258   1st Qu.:-0.17892   1st Qu.:0.14045   1st Qu.:14000  
##  Median :0.13733   Median :-0.13733   Median :0.17521   Median :14515  
##  Mean   :0.14016   Mean   :-0.14016   Mean   :0.17679   Mean   :14788  
##  3rd Qu.:0.17892   3rd Qu.:-0.10258   3rd Qu.:0.21617   3rd Qu.:15267  
##  Max.   :0.24051   Max.   :-0.04092   Max.   :0.26365   Max.   :21711  
##       NLI               NRVI            OSAVI             RDVI      
##  Min.   :0.07195   Min.   :0.2835   Min.   :0.1080   Min.   :11.38  
##  1st Qu.:0.14045   1st Qu.:0.4438   1st Qu.:0.2107   1st Qu.:22.19  
##  Median :0.17521   Median :0.5722   Median :0.2628   Median :27.71  
##  Mean   :0.17679   Mean   :0.5607   Mean   :0.2652   Mean   :27.64  
##  3rd Qu.:0.21618   3rd Qu.:0.6699   3rd Qu.:0.3243   3rd Qu.:33.37  
##  Max.   :0.26366   Max.   :0.8446   Max.   :0.3955   Max.   :41.14  
##      SR_B4            RVI              SAVI            SR_B6      
##  Min.   : 8408   Min.   :0.5828   Min.   :0.1080   Min.   : 9947  
##  1st Qu.: 9318   1st Qu.:0.6458   1st Qu.:0.2107   1st Qu.:11818  
##  Median :10112   Median :0.7031   Median :0.2628   Median :12900  
##  Mean   :10454   Mean   :0.7031   Mean   :0.2652   Mean   :13232  
##  3rd Qu.:11081   3rd Qu.:0.7559   3rd Qu.:0.3243   3rd Qu.:14260  
##  Max.   :18647   Max.   :0.8659   Max.   :0.3955   Max.   :21085  
##      SR_B7           SLAVI             TVI            wetness       
##  Min.   : 8724   Min.   :0.5360   Min.   :0.7563   Min.   :-6257.8  
##  1st Qu.:10040   1st Qu.:0.5702   1st Qu.:0.8000   1st Qu.:-3380.6  
##  Median :10910   Median :0.5876   Median :0.8215   Median :-2690.7  
##  Mean   :11236   Mean   :0.5884   Mean   :0.8220   Mean   :-2689.6  
##  3rd Qu.:12055   3rd Qu.:0.6081   3rd Qu.:0.8459   3rd Qu.:-1895.6  
##  Max.   :18274   Max.   :0.6318   Max.   :0.8739   Max.   : -547.3  
##       DEM             SLOPE            ASPECT      
##  Min.   : 903.2   Min.   :0.1086   Min.   :0.1948  
##  1st Qu.:1339.2   1st Qu.:0.2496   1st Qu.:1.5709  
##  Median :1481.1   Median :0.3087   Median :2.7044  
##  Mean   :1453.4   Mean   :0.3090   Mean   :2.9402  
##  3rd Qu.:1572.4   3rd Qu.:0.3648   3rd Qu.:4.3246  
##  Max.   :1918.2   Max.   :0.6088   Max.   :6.0094
```

```r 
summary(test_PP)
```

```r annotate 
##       FID            OBJECTI        N_Cintf              Dnm_cm     
##  Min.   :  10.0   Min.   : 3015   Length:140         Min.   :11.12  
##  1st Qu.: 851.5   1st Qu.: 3858   Class :character   1st Qu.:19.70  
##  Median :1290.5   Median : 4298   Mode  :character   Median :23.61  
##  Mean   :1304.3   Mean   : 7500                      Mean   :23.21  
##  3rd Qu.:1581.8   3rd Qu.: 4589                      3rd Qu.:26.76  
##  Max.   :2785.0   Max.   :46317                      Max.   :37.09  
##     Npies_h           AB_m2_h            Dmc_cm           Ho_m       
##  Min.   :  20.05   Min.   : 0.3896   Min.   :11.12   Min.   : 4.577  
##  1st Qu.: 260.65   1st Qu.:10.8463   1st Qu.:19.89   1st Qu.: 9.825  
##  Median : 481.19   Median :20.7148   Median :23.87   Median :11.392  
##  Mean   : 532.40   Mean   :23.4803   Mean   :23.52   Mean   :11.160  
##  3rd Qu.: 781.94   3rd Qu.:36.2221   3rd Qu.:27.11   3rd Qu.:12.707  
##  Max.   :1846.20   Max.   :63.6446   Max.   :37.09   Max.   :15.777  
##     Bttl_Kg            MgC.pr_           Ctt_MC.               HH         
##  Min.   :   4.819   Min.   :0.01961   Min.   :  0.3931   Min.   :0.02729  
##  1st Qu.: 352.909   1st Qu.:0.78962   1st Qu.: 15.8320   1st Qu.:0.12521  
##  Median : 573.988   Median :1.89119   Median : 37.9186   Median :0.17741  
##  Mean   : 640.514   Mean   :2.09958   Mean   : 42.0968   Mean   :0.18351  
##  3rd Qu.: 909.323   3rd Qu.:3.24580   3rd Qu.: 65.0787   3rd Qu.:0.22511  
##  Max.   :2165.582   Max.   :5.90087   Max.   :118.3131   Max.   :1.00861  
##        HV           vhAscDesc_2015      vhAsc_2015       vhDesc_2015     
##  Min.   :0.005401   Min.   :0.01979   Min.   :0.01043   Min.   :0.01234  
##  1st Qu.:0.034576   1st Qu.:0.02582   1st Qu.:0.02143   1st Qu.:0.02068  
##  Median :0.053534   Median :0.02832   Median :0.02748   Median :0.02782  
##  Mean   :0.052972   Mean   :0.02907   Mean   :0.03162   Mean   :0.03047  
##  3rd Qu.:0.068736   3rd Qu.:0.03179   3rd Qu.:0.03935   3rd Qu.:0.03799  
##  Max.   :0.122027   Max.   :0.06019   Max.   :0.10879   Max.   :0.07413  
##  vvAscDesc_2015      vvAsc_2015       vvDesc_2015          SR_B2      
##  Min.   :0.07594   Min.   :0.04594   Min.   :0.03886   Min.   : 7916  
##  1st Qu.:0.09505   1st Qu.:0.07325   1st Qu.:0.06855   1st Qu.: 8397  
##  Median :0.10770   Median :0.09796   Median :0.10066   Median : 8742  
##  Mean   :0.11109   Mean   :0.12863   Mean   :0.12838   Mean   : 8886  
##  3rd Qu.:0.12261   3rd Qu.:0.15800   3rd Qu.:0.16031   3rd Qu.: 9216  
##  Max.   :0.24180   Max.   :0.57784   Max.   :0.46730   Max.   :13953  
##    brightness         DVI            EVI               GNDVI       
##  Min.   :22785   Min.   :1751   Min.   :-19.2800   Min.   :0.1026  
##  1st Qu.:25662   1st Qu.:3633   1st Qu.:  0.9579   1st Qu.:0.1680  
##  Median :26851   Median :4567   Median :  1.3776   Median :0.2036  
##  Mean   :27118   Mean   :4436   Mean   :  1.3499   Mean   :0.1958  
##  3rd Qu.:28391   3rd Qu.:5417   3rd Qu.:  1.8295   3rd Qu.:0.2294  
##  Max.   :39184   Max.   :6090   Max.   : 10.9927   Max.   :0.2515  
##      SR_B3         greenness            GVI              LAI         
##  Min.   : 8535   Min.   :-3202.7   Min.   :0.5982   Min.   :-61.428  
##  1st Qu.: 9239   1st Qu.:-1440.4   1st Qu.:0.6282   1st Qu.:  2.928  
##  Median : 9649   Median : -560.8   Median :0.6619   Median :  4.263  
##  Mean   : 9854   Mean   : -739.4   Mean   :0.6747   Mean   :  4.175  
##  3rd Qu.:10268   3rd Qu.:  121.5   3rd Qu.:0.7126   3rd Qu.:  5.700  
##  Max.   :14913   Max.   :  706.1   Max.   :0.8141   Max.   : 34.839  
##       NBR               NDBI               NDVI             SR_B5      
##  Min.   :0.03846   Min.   :-0.23880   Min.   :0.06742   Min.   :11397  
##  1st Qu.:0.10567   1st Qu.:-0.18236   1st Qu.:0.14796   1st Qu.:14054  
##  Median :0.14478   Median :-0.14478   Median :0.18604   Median :14581  
##  Mean   :0.14262   Mean   :-0.14262   Mean   :0.18098   Mean   :14621  
##  3rd Qu.:0.18236   3rd Qu.:-0.10567   3rd Qu.:0.22026   3rd Qu.:15037  
##  Max.   :0.23880   Max.   :-0.03846   Max.   :0.25315   Max.   :19854  
##       NLI               NRVI            OSAVI             RDVI      
##  Min.   :0.06742   Min.   :0.3217   Min.   :0.1011   Min.   :10.87  
##  1st Qu.:0.14798   1st Qu.:0.4319   1st Qu.:0.2219   1st Qu.:22.97  
##  Median :0.18605   Median :0.5378   Median :0.2791   Median :29.21  
##  Mean   :0.18098   Mean   :0.5485   Mean   :0.2715   Mean   :28.31  
##  3rd Qu.:0.22026   3rd Qu.:0.6495   3rd Qu.:0.3304   3rd Qu.:34.42  
##  Max.   :0.25315   Max.   :0.8551   Max.   :0.3797   Max.   :38.88  
##      SR_B4            RVI              SAVI            SR_B6      
##  Min.   : 8476   Min.   :0.5961   Min.   :0.1011   Min.   :10006  
##  1st Qu.: 9345   1st Qu.:0.6395   1st Qu.:0.2219   1st Qu.:11885  
##  Median :10022   Median :0.6866   Median :0.2791   Median :12863  
##  Mean   :10185   Mean   :0.6968   Mean   :0.2715   Mean   :13010  
##  3rd Qu.:10830   3rd Qu.:0.7434   3rd Qu.:0.3304   3rd Qu.:13970  
##  Max.   :15557   Max.   :0.8739   Max.   :0.3797   Max.   :18500  
##      SR_B7           SLAVI             TVI            wetness       
##  Min.   : 8732   Min.   :0.5337   Min.   :0.7532   Min.   :-5906.1  
##  1st Qu.:10037   1st Qu.:0.5740   1st Qu.:0.8048   1st Qu.:-3306.4  
##  Median :10970   Median :0.5930   Median :0.8282   Median :-2695.4  
##  Mean   :11024   Mean   :0.5905   Mean   :0.8246   Mean   :-2673.1  
##  3rd Qu.:11807   3rd Qu.:0.6101   3rd Qu.:0.8486   3rd Qu.:-1896.1  
##  Max.   :15629   Max.   :0.6266   Max.   :0.8678   Max.   : -721.9  
##       DEM             SLOPE            ASPECT      
##  Min.   : 909.3   Min.   :0.1079   Min.   :0.5926  
##  1st Qu.:1387.6   1st Qu.:0.2301   1st Qu.:1.7874  
##  Median :1504.6   Median :0.3154   Median :2.8702  
##  Mean   :1458.8   Mean   :0.3003   Mean   :2.9709  
##  3rd Qu.:1566.4   3rd Qu.:0.3610   3rd Qu.:4.1765  
##  Max.   :1722.8   Max.   :0.4739   Max.   :6.0102
```

```r 
# Definición de parámetros de control para entrenamiento de modelo con caret
fitControl <- trainControl(
  method = "repeatedcv",  # Método de validación cruzada: validación cruzada repetida
  number = 10,            # Número de pliegues en la validación cruzada: 10
  repeats = 5,            # Número de repeticiones de la validación cruzada: 5
  returnResamp = "all",   # Devolver todas las métricas de evaluación para cada repetición
  returnData = TRUE,      # Devolver datos originales junto con predicciones del modelo
  savePredictions = TRUE  # Guardar las predicciones del modelo
)
```

#### Modelo *Pinus pinaster* de biomasa

```r 
model_PP_AGB <- train (Ctt_MC. ~ 
HH + HV +  vhDesc_2015 + vvAscDesc_2015+ vvAsc_2015    
+ vvDesc_2015 + SR_B2 + DVI +  LAI + NDBI          
+ DEM +  SLOPE +  ASPECT     
,data=train_PP, method="rf",
                trControl=fitControl,
                 prox=TRUE,
                 fitBest = TRUE,
                 )


model_PP_AGB
```

```r annotate 
## Random Forest 
## 
## 575 samples
##  13 predictor
## 
## No pre-processing
## Resampling: Cross-Validated (10 fold, repeated 5 times) 
## Summary of sample sizes: 519, 517, 517, 518, 518, 516, ... 
## Resampling results across tuning parameters:
## 
##   mtry  RMSE      Rsquared   MAE     
##    2    19.63748  0.6081623  15.25107
##    7    19.55525  0.6090764  14.94387
##   13    19.66404  0.6048545  14.94305
## 
## RMSE was used to select the optimal model using the smallest value.
## The final value used for the model was mtry = 7.
```

Hacemos una evaluación con el set de testeo

```r 
Predict_model_PP_AGB <- predict(model_PP_AGB, newdata=test_PP)

Observed_ctt <- test_PP$Ctt_MC.

tmp_ctt <- data.frame(Predict_model_PP_AGB, Observed_ctt)

ev<- caret::postResample(test_PP$Ctt_MC., Predict_model_PP_AGB)

ev
```

```r annotate 
##       RMSE   Rsquared        MAE 
## 18.6565594  0.6325228 13.4633422
```

Por ultimo graficamos el modelo observado vs el modelo predicho


```r 
m1_PN <- tmp_ctt %>% dplyr::select( Predict_model_PP_AGB, Observed_ctt) %>%
  pivot_longer(cols = -Observed_ctt) %>%
  ggplot(aes(x = Observed_ctt, y = value)) + geom_point()+
  stat_smooth(aes(), method="lm", formula=y ~ x) +theme_bw()+
  ylab("Model Pinud pinaster (Mg·ha−1)")+ xlab("observed (Mg·ha−1)")+
  ggtitle("MODEL RF PP VS OBSERVED",subtitle = "R2=0.49 - RSME= 21.43 - %RSME= 16.90%")+
  geom_abline(intercept=0, slope=1, lwd=1, linetype=2, color="red")

m1_PN 
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/m1_PN.png)

Utilizamos la funcion predict para crear el Raster del modelo generado para Pp. y guardamos en el disco.

```r 
MgC_PP<- predict(rasters1, model_PP_AGB)

plot(MgC_PP)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/MgC_PP.png)

```r 
#cortamos al area de los poligonos correspondientes a PP
MgC_PP_mask <- mask(MgC_PP, pinus_PP)

#Guardamos los resultados
writeRaster(MgC_PP_mask,filename = paste ("D:/cap_13_Radar/RESULTADOS/","MgC_PP_2015"), bylayer=TRUE, format="GTiff", overwrite=TRUE, sep="")
```

#### Modelo *Pinus halepensis* de biomasa

```r 
model_PH_AGB <- train (Ctt_MC. ~ 
HH + HV +  vhDesc_2015 + vvAscDesc_2015+ vvAsc_2015    
+ vvDesc_2015 + SR_B2 + DVI +  LAI + NDBI          
+ DEM +  SLOPE +  ASPECT    
,data=train_PH, method="rf",
                trControl=fitControl,
                 prox=TRUE,
                 fitBest = TRUE,
                 )


model_PH_AGB
```

```r annotate 
## Random Forest 
## 
## 506 samples
##  13 predictor
## 
## No pre-processing
## Resampling: Cross-Validated (10 fold, repeated 5 times) 
## Summary of sample sizes: 454, 455, 456, 455, 455, 457, ... 
## Resampling results across tuning parameters:
## 
##   mtry  RMSE      Rsquared   MAE     
##    2    13.32181  0.5018863  9.433272
##    7    13.60205  0.4725944  9.475126
##   13    13.79335  0.4581861  9.552726
## 
## RMSE was used to select the optimal model using the smallest value.
## The final value used for the model was mtry = 2.
```

Hacemos una evaluación con el set de testeo

```r 
Predict_model_PH_AGB <- predict(model_PH_AGB, newdata=test_PH)

Observed_ctt <- test_PH$Ctt_MC.

tmp_ctt <- data.frame(Predict_model_PH_AGB, Observed_ctt)

ev<- caret::postResample(test_PH$Ctt_MC. ,Predict_model_PH_AGB)

ev
```

```r annotate 
##       RMSE   Rsquared        MAE 
## 13.1817939  0.5657525  9.3199807
```

Por ultimo graficamos el modelo observado vs el modelo predicho


```r 
m1_PH <- tmp_ctt %>% dplyr::select( Predict_model_PH_AGB, Observed_ctt) %>%
  pivot_longer(cols = -Observed_ctt) %>%
  ggplot(aes(x = Observed_ctt, y = value)) + geom_point()+
  stat_smooth(aes(), method="lm", formula=y ~ x) +theme_bw()+
  ylab("Model RF Wt (Mg·ha−1)")+ xlab("observed (Mg·ha−1)")+
  ggtitle("MODEL RF Wt VS OBSERVED",subtitle = "R2=0.49 - RSME= 21.43 - %RSME= 16.90%")+
  geom_abline(intercept=0, slope=1, lwd=1, linetype=2, color="red")

 
m1_PH 
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/m1_PN.png)

Utilizamos la funcion predict para crear el Raster del modelo generado para Ph. y guardamos en el disco.

```r 
MgC_PH<- predict(rasters1, model_PH_AGB)

plot(MgC_PH)
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/MgC_PH.png)

```r 
 correspondientes a PP
MgC_PH_mask <- mask(MgC_PH, pinus_PH)

#Guardamos resultados en el disco
writeRaster(MgC_PH_mask,filename = paste ("D:/cap_13_Radar/RESULTADOS/","MgC_PH_2015"), bylayer=TRUE, format="GTiff", overwrite=TRUE, sep="")
```
