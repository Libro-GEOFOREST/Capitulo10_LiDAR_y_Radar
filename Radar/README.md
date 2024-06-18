
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
&gamma_{0}=10·log_{10}(DN^2) - 83.0 dB
```

```r
alos2_Gamma_dB <- 10 * log10 (alos2^2) - 83.0 
plot(alos2_Gamma_dB )
```

![](https://github.com/Libro-GEOFOREST/Capitulo10_LiDAR_y_Radar/blob/main/Auxiliares/ALOS2b.png)

A continuación, convierta los valores de dB a retrodispersión de potencia aplicando la siguiente ecuación:

```math
&gamma_{0}=10·log_{10}(DN^2) - 83.0 dB
```
