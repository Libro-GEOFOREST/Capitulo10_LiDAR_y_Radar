
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
S1_2015 <- stack(list.files(path="D:/cap_13_Radar/S1_2015_SPK",full.names=TRUE))

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

