[![DOI](https://zenodo.org/badge/694534100.svg)](https://zenodo.org/doi/10.5281/zenodo.10454197)

Mª Ángeles Varo Martínez y Rafael Mª Navarro Cerrillo

# Capítulo 10: Sensores activos en ciencias forestales: LiDAR

En el presente ejercicio se va a aprender a visualizar y manipular datos LiDAR para conseguir información de la estructura de la vegetación tanto a nivel de masa, como a nivel de árbol individual.

## 1. Descarga de datos LiDAR-PNOA

Para la descarga de datos LiDAR-PNOA de la primera cobertura, se aconseja que se sigan las instrucciones del siguiente video utilizando la zona de estudio descargable en [aqui](./Limite_monte) 

[<img src="https://img.youtube.com/vi/2u88We_Zyzg/0.jpg" width=100%>](https://www.youtube.com/watch?v=2u88We_Zyzg)

A modo de guía, se presentan algunas imágenes:

![](./Auxiliares/Descarga.png)

![](./Auxiliares/Descarga2.png)

![](./Auxiliares/Descarga3.png)

![](./Auxiliares/Descarga4.png)

![](./Auxiliares/Descarga5.png)

## 2. Visualización y comprobaciones previas

Dentro de un flujo de trabajo estándar con datos LiDAR, una de las primeras actividades a realizar es una comprobación previa de la nube de puntos que permitirá conocer si son útiles para el propósito que se les pretende asignar.

![](./Auxiliares/Flujo_LiDAR.png)

### 2.1. Introducir los archivos LiDAR

Para la visualización y manipulación de datos LiDAR en contexto forestal se va a emplear la interfaz que proporciona la librería *lidR* en lenguaje R.

```r
library(lidR)
```

#### 2.1.1. Como un catalogo de datos

Un catálogo de datos LiDAR consiste en una representación en R de un conjunto de archivos no cargados en memoria. El peso de los archivos .laz o .las, en ocasiones, es considerable. Cuando, además, se trata de datos con una alta densidad de pulsos, incluso puede fallar el cargar un único archivo. Empleando un catálogo de datos LiDAR, un ordenador o computadora normal podría trabajar con la nube, aunque no fuera capaz de cargarla en memoria.

```r
catalogo<-readLAScatalog("E:/DESCARGA") #Adaptar a la ruta de descarga utilizada
catalogo 
```

```r annotate
## class       : LAScatalog (v1.2 format 3)
## extent      : 534000, 538000, 4118000, 4122000 (xmin, xmax, ymin, ymax)
## coord. ref. : ETRS89 / UTM zone 30N 
## area        : 16 km²
## points      : 19.41million points
## density     : 1.2 points/m²
## num. files  : 4
```

Se puede observar que se trata de un conjunto de 4 archivos con una densidad media de los pulsos de 1.2 puntos/m^2^ que cubre una superficie de 16 km^2^. El sistema de coordenadas es el ETRS89 UTM zona 30N.

El formato LAS contiene datos que se pueden dividir en tres grupos:

-   Bloque de cabecera pública: incluye la información básica del fichero y datos genéricos como el número de puntos y las coordenadas de la extensión espacial que cubre la nube de puntos.

-   Registros de longitud variable: contiene diferentes tipos de datos incluyendo la proyección y los metadatos.

-   Registros de la nube de puntos.

Para ver el bloque de cabecera del catálogo, se puede acceder a la tabla en donde se guardan los principales datos de la cabecera de los archivos LiDAR.

```r
#Ver la cabecera de los datos
catalogo@data
```

File.Signature | File.Source.ID | GUID | Version.Major | Version.Minor | System.Identifier | Generating.Software | File.Creation.Day.of.Year | File.Creation.Year | Header.Size | Offset.to.point.data | Number.of.variable.length.records | Point.Data.Format.ID | Point.Data.Record.Length | Number.of.point.records | X.scale.factor | Y.scale.factor | Z.scale.factor | X.offset | Y.offset | Z.offset | Max.X | Min.X | Max.Y | Min.Y | Max.Z | Min.Z | CRS | Number.of.1st.return | Number.of.2nd.return | Number.of.3rd.return | Number.of.4th.return | Number.of.5th.return | filename
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---
LASF | 0 | 00000000-0000-0000-0000-000000000000 | 1 | 2 | | TerraScan | 13 | 2017 | 227 | 633 | 3 | 3 | 34 | 4976583 | 0.001 | 0.001 | 0.001 | 534000 | 4118000 | 0 | 536000 | 534000 | 4120000 | 4118000 | 1963.45 | 1843.33 | 25830 | 3893823 | 1072023 | 10705 | 32 | 0 | E:/DESCARGA/PNOA_2014_AND-SE_534-4120_ORT-CLA-CIR.laz
LASF | 0 | 00000000-0000-0000-0000-000000000000 | 1 | 2 | | TerraScan | 13 | 2017 | 227 | 633 | 3 | 3 | 34 | 4633930 | 0.001 | 0.001 | 0.001 | 534000 | 4120000 | 0 | 536000 | 534000 | 4122000 | 4120000 | 1991.47 | 1698.75 | 25830 | 3970075 | 660084 | 3718 | 53 | 0 | E:/DESCARGA/PNOA_2014_AND-SE_534-4122_ORT-CLA-CIR.laz
LASF | 0 | 00000000-0000-0000-0000-000000000000 | 1 | 2 | | TerraScan | 13 | 2017 | 227 | 633 | 3 | 3 | 34 | 5247509 | 0.001 | 0.001 | 0.001 | 536000 | 4118000 | 0 | 538000 | 536000 | 4120000 | 4118000 | 2060.91 | 1700.38 | 25830 | 4025607 | 1210920 | 10887 | 95 | 0 | E:/DESCARGA/PNOA_2014_AND-SE_536-4120_ORT-CLA-CIR.laz
LASF | 0 | 00000000-0000-0000-0000-000000000000 | 1 | 2 | | TerraScan | 13 | 2017 | 227 | 633 | 3 | 3 | 34 | 4550014 | 0.001 | 0.001 | 0.001 | 536000 | 4120000 | 0 | 538000 | 536000 | 4122000 | 4120000 | 2052.63 | 1547.24 | 25830 | 3698568 | 838536 | 12721 | 189 | 0 | E:/DESCARGA/PNOA_2014_AND-SE_536-4122_ORT-CLA-CIR.laz

En él se puede identificar la versión LAS de los datos, el ID del proyecto, el software generador, la fecha de creación del archivo y la extensión del proyecto, entre otra información.

Un paso importante en el procesado de datos LiDAR es asegurarse que los archivos están completos y son válidos. Para ello, se realiza una inspección de la consistecia de los archivos del catálogo a través de la función *las_check()*.

```r
#Validar los datos LiDAR
las_check(catalogo)
```

![](./Auxiliares/las_check.png)

La función muestra que existen incoherencias respecto a los offsets (compensaciones). Además indica que los datos no están normalizados, ni indexados.

Los campos de offsets deben usarse para establecer la compensación general para la localización de los registros de puntos. En general, estos números serán cero, pero en ciertos casos, la resolución de los datos de puntos puede no ser lo suficientemente grande para un sistema de proyección dado. Sin embargo, siempre se debe suponer que se utilizan estos números. Entonces, para escalar una X dada desde el registro de puntos, tome el registro de puntos X multiplicado por el factor de escala de X y luego agregue el desplazamiento de X.

$$X_{coordenada}=(X_{registrado} *X_{escalado} )+X_{offset} $$

$$Y_{coordenada}=(Y_{registrado} *Y_{escalado} )+Y_{offset} $$

$$Z_{coordenada}=(Z_{registrado} *Z_{escalado} )+Z_{offset} $$

```r
#Valores de offset de los archivos del catalogo. Coordenada X
catalogo@data$X.offset
```

```r annotate
## [1] 534000 534000 536000 536000
```

```r
#Valores de offset de los archivos del catalogo. Coordenada Y
catalogo@data$Y.offset
```

```r annotate
## [1] 4118000 4120000 4118000 4120000
```

```r
#Valores de offset de los archivos del catalogo. Coordenada Z
catalogo@data$Z.offset
```

```r annotate
## [1] 0 0 0 0
```

```r
#Valores mínimos de los archivos del catalogo. Coordenada X
catalogo@data$Min.X
```

```r annotate
## [1] 534000 534000 536000 536000
```

```r
#Valores máximos de los archivos del catalogo. Coordenada X
catalogo@data$Max.X
```

```r annotate
## [1] 536000 536000 538000 538000
```

```r
#Valores mínimos de los archivos del catalogo. Coordenada Y
catalogo@data$Min.Y
```

```r annotate
## [1] 4118000 4120000 4118000 4120000
```

```r
#Valores máximos de los archivos del catalogo. Coordenada Y
catalogo@data$Max.Y
```

```r annotate
## [1] 4120000 4122000 4120000 4122000
```

```r
#Valores mínimos de los archivos del catalogo. Coordenada Z
catalogo@data$Min.Z
```

```r annotate
## [1] 1843.33 1698.75 1700.38 1547.24
```

```r
#Valores máximos de los archivos del catalogo. Coordenada Z
catalogo@data$Max.Z
```

```r annotate
## [1] 1963.45 1991.47 2060.91 2052.63
```

El valor de los offsets en X e Y coinciden con sus valores mínimos respectivos en los 4 archivos. Resulta evidente que se trata de un error en la cabecera y que los valores de offset deberían ser 0 en las 3 dimensiones. Para corregir la incosistencia, se cambia el valor de los offsets:

```r
#Corregir la cabecera
catalogo@data$X.offset<-c(0,0,0,0)
catalogo@data$Y.offset<-c(0,0,0,0)

#Volvemos a comprobar la validacion de los datos
las_check(catalogo)#Ya está corregido
```

![](./Auxiliares/las_check2.png)

#### 2.1.2. Como un único archivo

Además del catálogo de datos LiDAR, también se puede visualizar un único archivo .las

```r
lidar534_4120<-readLAS("E:/DESCARGA/PNOA_2014_AND-SE_534-4120_ORT-CLA-CIR.laz") #Adaptar a la ruta de descarga utilizada
```

La estructura interna de los datos LiDAR se hace accesible al usuario a través de tablas de datos en los que queda recogido, como mínimo, el valor de:

-   Datos inerciales del avión (INS/IMU)
-   Coordenadas "X".
-   Coordenadas "Y".
-   Dato "Elevation": distancia a la superficie.
-   Información de posicionamiento GPS.
-   Dato "Intensidad" que es el valor adimensional de la energía recibida.
-   Número del pulso emitido.
-   Número del pulso reflejado.
-   Ángulo de escaneo.
-   Clasificación del punto.

A veces también se registra:

-   Si el pulso es límite de la linea de vuelo o no
-   Valores en R (Rojo), G (Verde), B (Azul) del color del retorno.

```r
#Vamos a ver el interior de los datos. Sólo los 6 primeros
head(lidar534_4120@data)
```
X | Y | Z | gpstime | Intensity | ReturnNumber | NumberOfReturns | ScanDirectionFlag | EdgeOfFlightline | Classification | Synthetic_flag | Keypoint_flag | Withheld_flag | ScanAngleRank | UserData | PointSourceID | R | G | B
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---
534000.0 | 4119123 | 1926.30 | 103038679 | 88 | 1 | 1 | 0 | 0 | 12 | FALSE | FALSE | FALSE | -16 | 0 | 197 | 41984 | 43008 | 37888
534000.0 | 4119123 | 1926.33 | 103038679 | 91 | 1 | 1 | 0 | 0 | 12 | FALSE | FALSE | FALSE | -16 | 0 | 197 | 41728 | 42752 | 37632
534000.1 | 4119123 | 1926.30 | 103038679 | 84 | 1 | 1 | 0 | 0 | 12 | FALSE | FALSE | FALSE | -16 | 0 | 197 | 41472 | 42496 | 37376
534000.1 | 4119122 | 1926.28 | 103038679 | 86 | 1 | 1 | 0 | 0 | 12 | FALSE | FALSE | FALSE | -16 | 0 | 197 | 41216 | 41984 | 36864
534000.2 | 4119122 | 1926.22 | 103038679 | 86 | 1 | 1 | 0 | 0 | 12 | FALSE | FALSE | FALSE | -16 | 0 | 197 | 40960 | 41472 | 36608
534000.2 | 4119122 | 1926.22 | 103038679 | 89 | 1 | 1 | 0 | 0 | 12 | FALSE | FALSE | FALSE | -16 | 0 | 197 | 40960 | 41216 | 36352

### 2.2. Comprobaciones de la información LiDAR

Cuando se recibe un vuelo LiDAR generado por una empresa es necesario realizar un control de calidad para ratificar que los datos cumplen con las condiciones que se han especificado en el pliego de especificaciones técnicas y tienen las condiciones necesarias para el objetivo de nuestro proyectos. Además nos permite indagar las posibles mejoras en las especificaciones de los vuelos futuros según las particularidades de la masa.

#### 2.2.1. Visualizar los datos LiDAR

Visualizar un catalogo de datos LiDAR sobre un mapa permite comprobar que se ajusta a la zona de estudio seleccionada.

```r
#Visualizar el catalogo sobre un mapa
#Necesita tener instalada la libreria mapview
#En caso de no tenerla instalada ejecutar la función install.packages()
#install.packages("mapview")
library(mapview)
plot(catalogo, map = TRUE, map.type = "Esri.WorldImagery")
```

![](./Auxiliares/mapa.png)

Para visualizar la nube de puntos en 3 dimensiones se ha seleccionado una zona según sus coordenadas.

##### Con un solo archivo

```r
#Visualizar en 3D
recorte<-clip_rectangle(lidar534_4120, 
                        min(lidar534_4120$X)+1850, 
                        min(lidar534_4120$Y)+1170, 
                        min(lidar534_4120$X)+2000,  
                        min(lidar534_4120$Y)+1320)

plot(recorte)
```

![](./Auxiliares/recorte.png)

Se pueden cambiar algunas opciones para mejorar la visualización de los datos como el fondo, la presencia de ejes guía en cada dimensión y la presencia de leyenda del mapa.

```r
plot(recorte,bg = "white", axis = TRUE, legend = TRUE)
```

![](./Auxiliares/recorte2.png)

##### Con un catálogo de datos

Para visualizar esta misma zona trabajando desde el catálogo, es necesario ejecutar la función *readLAS()* de la zona que se quiera visualizar, filtrando las coordenadas para no exceder la memoria. Como el primero de los archivos del catálogo es el que corresponde al que se ha visualizado en el paso anterior,

```r
#Nombre de los archivos del catalogo
catalogo@data$filename
```

```r annotate
## [1] "E:/DESCARGA/PNOA_2014_AND-SE_534-4120_ORT-CLA-CIR.laz"
## [2] "E:/DESCARGA/PNOA_2014_AND-SE_534-4122_ORT-CLA-CIR.laz"
## [3] "E:/DESCARGA/PNOA_2014_AND-SE_536-4120_ORT-CLA-CIR.laz"
## [4] "E:/DESCARGA/PNOA_2014_AND-SE_536-4122_ORT-CLA-CIR.laz"
```

```r
#Coordenada X mínima del recorte
catalogo@data$Min.X[1]+1850
```

```r annotate
## [1] 535850
```

```r
#Coordenada Y mínima del recorte
catalogo@data$Min.Y[1]+1170
```

```r annotate
## [1] 4119170
```

```r
#Coordenada X máxima del recorte
catalogo@data$Min.X[1]+2000
```

```r annotate
## [1] 536000
```

```r
#Coordenada Y máxima del recorte
catalogo@data$Min.Y[1]+1320
```

```r annotate
## [1] 4119320
```

```r
#Visualizar recorte del catalogo
recorte_catalogo<-readLAS((catalogo[[34]][1]),select = "xyz",
               filter="-keep_xy 535850 4119170 536000 4119320")

plot(recorte_catalogo)
```

![](./Auxiliares/recorte1b.png)

Como se puede observar, el resultado es el mismo.

#### 2.2.2. Distribución espacial de la densidad de pulsos

Una de las comprobaciones cruciales es la densidad de pulsos. Con ella se puede determinar si la nube de puntos resulta útil para la finalidad que se le quiera dar según el tipo de masa forestal con la que se esté trabajando. Ya se había determinado en el punto 2.1.1. que los datos que se están usando tienen una densidad media de puntos de 2.1.2. Sin embargo, la distribución de los pulsos puede variar espacialmente en el área de estudio.

Con la función *retrieve_pulses()* se consigue recuperar cada pulso individual usando el tiempo GPS para identificarlos y guardándolo como un atributo extra. A través de él, se consigue crear un mapa de densidades de retornos y de pulsos.

```r
lidar534_4120 <- retrieve_pulses(lidar534_4120)

densidad<-grid_density(lidar534_4120, res = 5)
densidad
```

```r annotate
## class      : RasterBrick 
## dimensions : 400, 400, 160000, 2  (nrow, ncol, ncell, nlayers)
## resolution : 5, 5  (x, y)
## extent     : 534000, 536000, 4118000, 4120000  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : point_density, pulse_density 
## min values :             0,             0 
## max values :         68.92,         51.08
```

```r
#Caracterizacion del raster como de valores discretos
library(raster)
densidad[[2]] <- ratify(densidad[[2]])

library(mapview)
mapview(densidad[[2]],
        col.regions = c("red","green","darkgreen","yellow","orange","red","brown"),
        at = c(0,0.3,1,2,3,4,5))
```

![](./Auxiliares/densidad.png)

##### Con un catálogo de datos

Para trabajar desde el catalogo de datos LiDAR, se pueden usar las mismas funciones, sustituyendo el argumento *lidar534_4120* por *catalogo*. Los resultados serán extensibles a toda la zona de los 4 archivos LiDAR descargados. El tiempo de procesado se verá incrementado proporcionalmente al aumento de superficie.

```r
densidad_catalogo<-grid_density(catalogo, res = 5)
densidad_catalogo
```

```r annotate
## class      : RasterLayer 
## dimensions : 800, 800, 640000  (nrow, ncol, ncell)
## resolution : 5, 5  (x, y)
## extent     : 534000, 538000, 4118000, 4122000  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : layer 
## values     : 0, 68.92  (min, max)
```

![](./Auxiliares/densidad_catalogo.png)

```r
mapview(densidad_catalogo,
        col.regions = c("red","green","darkgreen","yellow","orange","red","brown"),
        at = c(0,0.3,1,2,3,4,5))
```

![](./Auxiliares/densidad_catalogo2.png)

Como puede comprobarse, aunque el valor medio de la densidad de puntos del archivo (1.2) supera con creces los requisitos del proyecto LiDAR-PNOA (0.5 pulsos/m^2^), la distribución de los mismos no es homogenea. En las zonas de solape entre líneas de vuelo es considerablemente mayor que en las posiciones intermedias, en las que llegan a encontrarse huecos. Dicha distribución tendrá consecuencias en la obtención de las variables dasométricas del inventario.

#### 2.2.3. Comprobar clasificación de los datos

Cuando en el Pliego de Prescripciones Tecnicas solicitado en un vuelo LiDAR se indica la necesidad de realizar una clasificación de los puntos, es necesario su comprobación.

La sociedad americana de fotogrametría y teledetección (ASPRS) establece la codificación de las clasificaciones de puntos LiDAR según la siguiente tabla:

![](./Auxiliares/clasificacion.png)

En nuestros datos la clasificación es la siguiente.

```r
table(lidar534_4120@data$Classification)
```

```r annotate
## 
##       2       3       4       5       7      12 
## 1233623  115399  100706 1141412  327041 2058402
```

En los datos hay puntos clasificados como suelo (2), vegetación baja (3), media (4) y alta (5), puntos anómalos o ruido (7) y, en este caso, se emplea el valor reservado 12 para incluir los puntos localizados en la zona de solape entre líneas de vuelo.

También se puede visualizar la nube de puntos según la clasificación que ha recibido cada punto.

```r
plot(recorte,color="Classification",axis = TRUE, legend = TRUE)
```

![](./Auxiliares/clasificacion2.png)

O comprobar los retornos que han sido clasificados como suelo.

Una de las actividades fundamentales en el flujo de trabajo del procesado LiDAR consiste en una adecuada clasificación de los puntos de suelo. La bondad de dicha tarea repercutirá en que las alturas de la vegetación obtenidas en procesados posteriores se ajusten a la realidad. Por eso, merece la pena dedicar un tiempo en este paso. Idealmente, se debería disponer de un conjunto de no menos de 8 puntos del terreno, bien distribuídos sobre la superficie, en los que se hayan tomado sus coordenadas con un GPS de precisión subcentimétrica. De la diferencia entre las coordenadas medidas en campo con las clasificadas como suelo en la nube de puntos, se obtendría una medición del error en la clasificación del suelo. En la práctica, una buena observación de la nube de puntos según su clasificación en toda la zona de estudio es suficiente.

```r
#Ver puntos clasificados como suelo
plot(recorte[which(recorte$Classification==2),],
     color="Classification",axis = TRUE)
```

![](./Auxiliares/suelo.png)

#### 2.2.4 Comprobacion de ángulos de escaneo de vuelo

Los ángulos de escaneo en el vuelo también son un elemento clave que puede determinar si la nube de puntos adecuada a nuestros propósitos.

Generalmente, un ángulo de escaneo amplio va a suponer un ancho de pasada mayor y un menor número de pasadas en el vuelo, que repercutirán en un abaratamiento de los costes. Sin embargo, si el ángulo es demasiado grande, se generarán sombras y oclusiones que no permitirán al láser alcanzar el suelo. Es difícil determinar un ángulo límite, ya que la orografía del terreno y el tipo de vegetación también tienen cierto grado de influencia en el resultado. Sin embargo, ángulos de escaneo superiores a 40º se consideran demasiado elevados.

```r
summary(lidar534_4120@data$ScanAngleRank)
```

```r annotate
##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
## -21.0000 -11.0000  -2.0000   0.1381  13.0000  26.0000
```

```r
#Ver puntos según su ángulo de escaneo
plot(recorte,color="ScanAngleRank",axis = TRUE)
```

![](./Auxiliares/angulo_escaneo.png)

#### 2.2.5. Comprobar solapes entre líneas de vuelo

Uno de los requisitos de los vuelos es que las pasadas tengan un porcentaje de recubrimiento o solape mínimo entre ellas ya que dichas zonas de solape se utilizan para restituir el vuelo y hacer el ajuste de pasadas. Es importante que dicha tarea se haya ejecutado correctamente y los puntos converjan a la misma altura.

```r
#Ver puntos clasificados como solape
plot(recorte[which(recorte$Classification==12),],
     color="Classification",axis = TRUE)
```

![](./Auxiliares/lineas_escaneo.png)

```r
solape <- grid_metrics(lidar534_4120,
                           ~max(Classification), 
                           filter=~Classification == 12, res=5)
solape
```

```r annotate
## class      : RasterLayer 
## dimensions : 400, 400, 160000  (nrow, ncol, ncell)
## resolution : 5, 5  (x, y)
## extent     : 534000, 536000, 4118000, 4120000  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : V1 
## values     : 12, 12  (min, max)
```

```r
mapview(solape)
```

![](./Auxiliares/solape.png)

#### 2.2.6. Comprobar líneas de vuelo

A veces, cuando la restitución de las nubes de puntos de las líneas de vuelo no escorrecta, o los solapes contienen errores, se puede hacer necesario recuperar las líneas de vuelo.

```r
table(lidar534_4120@data$PointSourceID)
```

```r annotate
## 
##     197     198     199 
## 1584834 2537227  854522
```

Como puede comprobarse, en el archivo participan 3 líneas de vuelo. Se puede visualizar su distribución espacial reconstruyendo las líneas de vuelo a través de los tiempos GPS asociados a cada pulso a través de la función *retrieve_flightlines()*.

```r
lidar534_4120<-retrieve_flightlines(lidar534_4120, dt = 30)
plot(lidar534_4120, color = "flightlineID")
```

![](./Auxiliares/lineas_vuelo.png)

Y también se puede estimar la posición del sensor y, por tanto, la del avión o UAV en el que iba montado, a través de la función *track_sensor()*

```r
#Estimación de la posición del sensor con un archivo
lineas_vuelo <- track_sensor(lidar534_4120, 
                             Roussel2020(pmin = 15))
lineas_vuelo
```

```r annotate
## class       : SpatialPointsDataFrame 
## features    : 149 
## extent      : 533506.3, 536441.1, 4117610, 4119889  (xmin, xmax, ymin, ymax)
## crs         : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## variables   : 4
## names       :        Z,   gpstime, PointSourceID, SCORE 
## min values  : 3173.555, 103038679,           197,    18 
## max values  : 4588.697, 103040020,           199,   500
```

El resultado corresponde a una tabla de puntos con información espacial asociada con la situación del sensor en el recorrido de las líneas de vuelo. Podría, por tanto, guardarse como un archivo tipo shapefile.

```r
x<-plot(lidar534_4120)
add_flightlines3d(x, lineas_vuelo, radius = 10)
```

![](./Auxiliares/lineas_vuelo2.png)

Para un catálogo de datos, se haría de la siguiente forma:

```r
#Estimación de la posición del sensor para un catálogo
lineas_vuelo_catalogo <- track_sensor(catalogo, 
                             Roussel2020(pmin = 15))
plot(catalogo)
plot(lineas_vuelo_catalogo, add = TRUE)
```

![](./Auxiliares/lineas_vuelo3.png)

### 2.3. Crear raster de intensidades

Actualmente existen gran variedad de catálogos de imágenes que podemos descargar de forma gratuita en los distintos nodos IDE (REDIAM y centros de descarga de IGN fundamentalmente en España). Sin embargo, en ocasiones, no existe una ortofografía de referencia de la zona del vuelo. Para suplirla, se puede utilizar el valor de las intensidades de los pulsos.

Como ya se ha visto, el dato de intensidad del retorno está vinculado con la relación entre la cantidad de la energía del láser detectada por el receptor para un punto de reflexión determinado con respecto a la cantidad de energía total emitida para el pulso de láser. Debido a que esta relación es bastante pequeña, los valores de intensidad reportados en los datos LIDAR se escalan para una gama más útil (valores de 8 bits son comunes). Aunque, si bien los datos de intensidad están disponibles, su uso en los flujos de trabajo de procesamiento de datos es limitada.

Se va a generar un raster con una resolución de 5 m, en el que el valor de los píxeles corresponda con el valor medio de las intensidades de los primeros retornos. Se seleccionan los primeros retornos porque se asume que coincidirán con los más altos y así se eliminan los retornos del interior de la masa forestal, que no nos servirían para recrear la ortofotografía.

En la mayoría de los casos, se desean crear imágenes usando un tamaño de píxel en función de la huella de pulso utilizada y la separación entre pulsos. Por ejemplo, si los datos LIDAR se adquieren a una densidad de 4 pulses/m^2^ utilizando un tamaño de huella de 0,6 m, sería deseable crear imágenes que utilizan los píxeles de alrededor de 0,25 m^2^. En teoría, esto es posible. En la práctica, sin embargo, una gran proporción de píxeles no tienen información de retornos LiDAR que deberá rellenarse por la falta de uniformidad de la separación horizontal de los puntos dentro de la nube de datos LiDAR. La mayoría de estos vacíos se podrían llenar después de completar esta primera rasterización empleando técnicas de interpolación. No obstante, la interpolación podría ser engañosa ya que el material asociado con el píxel no es el promedio de los materiales circundantes.

```r
#Ver puntos según su intensidad
plot(recorte,color="Intensity",
     colorPalette=gray.colors(10, start = 0, end = 1))
```

![](./Auxiliares/intensidad.png)

```r
#Generar raster de intensidades
intensidad <- grid_metrics(lidar534_4120,
                           ~mean(Intensity), 
                           filter=~ReturnNumber == 1, res=5)

intensidad
```

```r annotate
## class      : RasterLayer 
## dimensions : 400, 400, 160000  (nrow, ncol, ncell)
## resolution : 5, 5  (x, y)
## extent     : 534000, 536000, 4118000, 4120000  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : V1 
## values     : 8, 241.4286  (min, max)
```

Y lo visualizamos el resultado sobre un mapa.

```r
library(mapview)
mapview(intensidad, 
        col.regions=gray.colors(255, start = 0, end = 1),na.color="red", map.type = "Esri.WorldImagery")

```

![](./Auxiliares/intensidad2.png)

## 3. Generación de Modelo del Terreno, Modelo de Superficies y Modelo de Vegetación

### 3.1. Generar el modelo digital del terreno o MDT

Un Modelo Digital del Terreno o MDT es una estructura numérica de datos que representa la distribución espacial de la variable elevación de forma cuantitativa y continua.

La selección de la resolución del MDT es uno de los problemas clave del modelado digital del terreno. Para decidir el tamaño del pixel que tendrá el MDT, se revisa el número de puntos que tenemos clasificados como suelo.

```r
#Densidad media de puntos clasificados como suelo
density(lidar534_4120[which(lidar534_4120@data$Classification==2),])
```

```r annotate
## [1] 0.3084148
```

```r
#Separación media entre puntos clasificados como suelo
1/sqrt(density(lidar534_4120[which(lidar534_4120@data$Classification==2),]))
```

```r annotate
## [1] 1.800663
```

La resolución para el MDT, teniendo en cuenta la densidad media de puntos de la nube clasificados como suelo, podría ser de 2 m. Sin embargo, también debe tenerse en cuenta la distribución espacial de la densidad de pulsos.

```r
#Evaluación de la distribución espacial de puntos clasificados como suelo
densidad_suelo<-grid_density(lidar534_4120[which(lidar534_4120@data$Classification==2),], res = 5)
densidad_suelo
```

```r annotate
## class      : RasterLayer 
## dimensions : 400, 400, 160000  (nrow, ncol, ncell)
## resolution : 5, 5  (x, y)
## extent     : 534000, 536000, 4118000, 4120000  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : layer 
## values     : 0, 2.36  (min, max)
```

```r
#Visualización de la distribución espacial de la densidad de los puntos de suelo
library(mapview)
mapview(densidad_suelo[[1]],
        col.regions = c("red","green","darkgreen","yellow","orange","red","brown"),
        at = c(0,0.05,0.1,0.2,0.3,0.4,0.5,2))
```

![](./Auxiliares/densidad_suelo.png)

Se observa en el mapa que existen zonas con densidades de puntos de suelo por debajo de la densidad media. Sería conveniente generar el modelo, teniéndolas en cuenta y, por eso, se ajusta a la separación máxima de pulsos proveniente de los valores mínimos de densidad de puntos de suelo. 

```r
#Separación entre pulsos
1/sqrt(0.05)
```

```r annotate
## [1] 4.472136
```

Se generará, por tanto, el MDT con un tamaño de píxel de 5m, redondeando el valor de la separación entre pulsos.

Ahora, se va a emplear la función *grid_terrain* para realizar la interpolación de dichos puntos de suelo. Se trata de una función que puede trabajar tanto con archivos .las, como con catálogo de datos LiDAR. De los distintos métodos de interpolación espacial que permite la herramienta, se ha seleccionado un algoritmo basado en una red de triangulación *tin()*. Este enfoque incluye dos pasos. Primero, se realiza una triangulación de Delaunay de puntos distribuidos irregularmente. Y, en segundo lugar, se estiman los valores de elevación en los nodos regulares de la cuadrícula. Los triángulos se unen ajustando un plano a tres puntos contiguos, formando un mosaico sobre el terreno que puede adaptarse a la superficie con diferente grado de detalle, en función de la complejidad del relieve.

```r
mdt <- grid_terrain(lidar534_4120, res = 5, algorithm=tin())

mdt
```

```r annotate
## class      : RasterLayer 
## dimensions : 400, 400, 160000  (nrow, ncol, ncell)
## resolution : 5, 5  (x, y)
## extent     : 534000, 536000, 4118000, 4120000  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : Z 
## values     : 1843.864, 1960.49  (min, max)
```

Y se visualizan los resultados:

```r
mapview(mdt,col = terrain.colors(50),maxpixels=1000000,
        map.type = "Esri.WorldImagery")
```

![](./Auxiliares/mdt.png)

Como puede apreciarse, los valores de alturas del terreno en esta zona varían entre los 1843 m y los 1960 m de altitud.

#### 3.1.1. Mapas auxiliares del terreno

Los MDT permiten construir una serie de modelos derivados elaborados a partir de la información en él contenida y reflejan características morfológicas simples, como la pendiente o la orientación. Incorporando dicha información es posible mejorar la toma de decisiones en la gestión de masas forestales. 

##### Pendientes
```r
#Cálculo de la pendiente del terreno en radianes
pendiente_rad <- terrain(mdt, opt='slope')

#Cálculo de la pendiente del terreno en grados
pendiente_grados <- terrain(mdt, opt='slope',unit="degrees")

#Visualización de los resultados
mapview(pendiente_grados,col = terrain.colors(50),maxpixels=1000000,
        map.type = "Esri.WorldImagery")
```

![](./Auxiliares/pendientes.png)

##### Orientaciones
```r
#Cálculo de las orientaciones del terreno
orientacion_rad <- terrain(mdt, opt='aspect')
orientacion_grados <- terrain(mdt, opt='aspect',unit="degrees")

# Convertir un raster continuo en un raster categorico a través de una matriz
matriz_reclas<-c(0,22.5,1,
                 22.5,67.5,2,
                 67.5,112.5,3,
                 112.5,157.5,4,
                 157.5,202.5,5,
                 202.5,247.5,6,
                 247.5,292.5,7,
                 292.5,337.5,8,
                 337.5,360,1)

matriz_reclas<-matrix(matriz_reclas,ncol=3,byrow=TRUE)

orientacion_reclas <- reclassify(orientacion_grados, 
                                 rcl = matriz_reclas)

orientacion_reclas <- ratify(orientacion_reclas)

# Añadir los nombres de cada clase
levels(orientacion_reclas)[[1]]$label <- c("Norte", "Noreste","Este",
                                           "Sureste","Sur","Suroeste",
                                           "Oeste","Noroeste")
levels(orientacion_reclas)
```

```r annotate
## [[1]]
##   ID    label
## 1  1    Norte
## 2  2  Noreste
## 3  3     Este
## 4  4  Sureste
## 5  5      Sur
## 6  6 Suroeste
## 7  7    Oeste
## 8  8 Noroeste
```

```r
#Visualizar orientaciones
mapview(orientacion_reclas,
        col.regions = c("red","orange","yellow","green",
                        "cyan","deepskyblue2","blue","deeppink"),
        maxpixels=1000000, map.type = "Esri.WorldImagery")
```

![](./Auxiliares/orientaciones.png)

##### Mapa de Sombras
```r
sombras <- hillShade(pendiente_rad, orientacion_rad, angle=45, direction=315)

mapview(sombras,col.regions=hcl.colors(255,"Gray"),maxpixels=1000000,
        map.type = "Esri.WorldImagery")
```

![](./Auxiliares/sombras.png)

### 3.2. Generar el modelo digital de superficies o MDS

La superficie topográfica que incluye todos los objetos que hay sobre el terreno como edificios, vegetación, carreteras y elementos naturales del terreno constituye el modelo digital de superficies o MDS. Se obtiene mediante la interpolación de los puntos más altos de cada tamaño de pixel. 

```r
lidar534_4120.mas.altos<-decimate_points(lidar534_4120, highest(res=5))

mds<-grid_canopy(lidar534_4120.mas.altos,res=5,dsmtin(max_edge=0))

mds
```

```r annotate
## class      : RasterLayer 
## dimensions : 400, 400, 160000  (nrow, ncol, ncell)
## resolution : 5, 5  (x, y)
## extent     : 534000, 536000, 4118000, 4120000  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : Z 
## values     : 1847.705, 1962.222  (min, max)
```

Y su visualización

```r
mapview(mds,col.regions=hcl.colors(255,"Gray"),maxpixels=1000000)
```

![](./Auxiliares/mds.png)

Aunque no difiere mucho del MDT, en el mapa se pueden intuir zonas rasas sin arbolado y zonas con vegetación.

### 3.3. Generar el modelo digital normalizado de superficies (nMDS) o modelo digital de vegetación o de copas (MDC)

El modelo de superficies normalizado consiste en el mismo modelo digital de superficies en el que todos sus elementos se encuentran referenciados respecto al suelo, lo que permite conocer la altura de cada elemento. Cuando dicho modelo se encuentra sobre una superficie forestal se le conoce como modelo de vegetación o de copas. Este modelo aporta información de la altura absoluta de la vegetación, donde se pueden medir alturas del arbolado. A partir de este modelo se pueden obtener subproductos relativos a intervalos de la vegetación, clasificándola como vegetación baja, media y alta. De igual forma, cuando se encuentra sobre una ciudad se conoce como modelo digital de edificios.

#### 3.3.1. Método de diferencias

En este método el modelo digital de vegetación se obtiene mediante la sustracción del modelo del terreno al modelo de superficies como un simple cálculo matemático. 

```r
nmds1<-mds-mdt

nmds1
```

```r annotate
## class      : RasterLayer 
## dimensions : 400, 400, 160000  (nrow, ncol, ncell)
## resolution : 5, 5  (x, y)
## extent     : 534000, 536000, 4118000, 4120000  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : layer 
## values     : -2.018, 21.051  (min, max)
```

Si se observa el rango de valores del raster resultante aparecen valores negativos. Sin embargo, cuando se estudia el histograma de los datos, se puede concluir que su número no es representativo y, salvo algunos datos aislados, la mayorìa de ellos no alcanzan los 20 cm de diferencia con la superficie.

```r
hist(nmds1,breaks=250,xlim=c(-2.5,0))
```

![](./Auxiliares/histograma.png)

Y se visualiza:

```r
mapview(nmds1,col.regions=rev(hcl.colors(17,"Spectral")),
        at = c(-Inf,0,1,2,3,4,5,6,7,8,9,10,11,13,14,15),maxpixels=1000000)
```

![](./Auxiliares/nmds1.png)

Como se observa en el mapa, la vegetación de la zona alcanza alturas inferiores a 15 m.

#### 3.3.2.Método de normalización de la nube de puntos

En este método el modelo digital de vegetación se obtiene mediante la interpolación de los puntos clasificados como suelo y vegetación. 

```r
archivo_norm<-normalize_height(lidar534_4120, tin())
```

Para visualizar el resultado, se va a utilizar un recorte de la zona

```r
recorte_norm<-clip_rectangle(archivo_norm,
                             min(archivo_norm$X)+1850,
                             min(archivo_norm$Y)+1170,
                             min(archivo_norm$X)+2000,
                             min(archivo_norm$Y)+1320)

plot(recorte_norm,bg = "white", axis = TRUE, 
     legend = TRUE,size = 3)
```

![](./Auxiliares/normalizado.png)

Se puede comparar esta imagen con la generada en la visualización de los datos sin normalizar del ejercicio de visualización de datos LiDAR y cómo el efecto del terreno ha desaparecido.

Y ahora, se rasteriza el resultado de forma análoga a como se hizo con el modelo de superficies. 

```r
nmds2<-grid_canopy(archivo_norm,res=2,dsmtin(max_edge=0))

nmds2
```

Finalmente, se visualizan los resultados.
```r
mapview(nmds2,col.regions=rev(hcl.colors(17,"Spectral")),
        at = c(-Inf,0,1,2,3,4,5,6,7,8,9,10,11,13,14,15),
        maxpixels=1000000)
```

![](./Auxiliares/nmds2.png)

## 4. Extracción de métricas de parcela y modelización de variables de inventario

Siguiendo el flujo de trabajo habitual de un inventario LiDAR trabajando a nivel de masa, tras la normalización de los pulsos, se llevaría a cabo la extracción de las métricas de las parcelas y su modelización con las variables de campo.

Es importante que durante la fase de campo se hayan seleccionado las parcelas cubriendo toda la variabilidad de la masa. De esta manera el modelo que se genere, represente todo el rango de datos del monte.

### 4.1. Introducir los datos necesarios

Se introducen los datos LiDAR normalizados en el ejercicio anterior. Para seleccionar sólo los que están normalizados y evitar los originales, se selecciona empleando el patrón del sufijo *norm* con los que lse guardaron.

```r
library(lidR)

#Introducir los archivos LiDAR como un catalogo de datos
catalogo_norm<-readLAScatalog(folder="E:/DESCARGA/",     #Adaptar a la ruta de descarga utilizada
                              pattern = "norm.las")
```

Se necesita una muestra de parcelas de campo donde se realicen mediciones de las variables de masa que se quieran estimar y de donde tengamos información LiDAR. Se introducen, por tanto, los datos de las mediciones de las parcelas de campo, a través del excel [colgado en la plataforma](https://github.com/Libro-GEOFOREST/Capitulo13_LiDAR_y_Radar/tree/main/DatosTrabajodeCampo) y que se debe haber descargado previamente.

```r
library(readxl)

#Leer archivo con datos de campo
campo<-read_excel("E:/DESCARGA/DatosTrabajodeCampo/resultado parcelas.xls")  #Adaptar a la ruta de descarga utilizada

#Convertir la tabla en un data frame
campo<-as.data.frame(campo)
```

Se comprueba la tabla de datos de campo.

```r
#Ver la tabla de datos
View(campo)
```

Parcela | Radio | N_pies_ha | G_m2_ha | Dg_cm | dmedio_cm | Ho_Assman_m | hmedia_m
--- | --- | --- | --- | --- | --- | --- | ---
1 | 11 | 552.4426 | 13.81511 | 17.84379 | 17.17500 | 9.144 | 8.230550
10 | 11 | 499.8290 | 11.93160 | 17.43380 | 17.23158 | 8.870 | 7.367421
11 | 11 | 1236.4191 | 28.62428 | 17.16872 | 17.17391 | 8.670 | 8.840000
12 | 11 | 894.4309 | 26.16349 | 19.29869 | 18.76765 | 9.410 | 8.480647
13 | 11 | 1052.2716 | 24.97441 | 17.38350 | 17.25641 | 10.310 | 8.847025
14 | 11 | 1078.5784 | 20.72051 | 15.63968 | 15.39756 | 7.460 | 6.714585
  
A continuación, se introducen ahora las coordenadas con la localización de las parcelas. Es necesario que dicha localización debe ser lo suficientemente precisa como para evitar que se confundan las zonas medidas en campo y las zonas de las que se extrae la estadística LiDAR. Por ejemplo, un GPS con un error de medición de varios metros podría "transportar" la parcela medida a un cortafuegos o un camino forestal, cuyas métricas LiDAR no tendrían nada que ver con la de la vegetación que se ha medido en campo.

```r
#Introducir coordenadas de las parcelas
library(sf)
```

```r
coord.parc<-st_read("E:/DESCARGA/DatosTrabajodeCampo/coordenadas_parcelas.shp")  #Adaptar a la ruta de descarga utilizada
```

Y se visualiza la tabla asociada al archivo shapefile.

```r
#Ver la tabla de datos
View(as.data.frame(coord.parc))
```

ID | Parcela | geometry
--- | --- | ---
1 | 1 | POINT (535750 4118454)
2 | 2 | POINT (535350 4118554)
3 | 3 | POINT (535050 4118654)
4 | 4 | POINT (535350 4118754)
5 | 5 | POINT (534750 4118654)

La representación cartográfica de las parcelas sobre la zona de vuelo LiDAR descargada quedaría así:

```r
#Representación cartográfica de las parcelas
library(mapview)

mapa1<-mapview(catalogo_norm, alpha.regions = 0, color = "red", 
        lwd = 2, layer.name = "Datos LiDAR",
        map.type = "Esri.WorldImagery",legend=FALSE)

mapa2<-mapview(coord.parc,zcol="Parcela", layer.name="Parcelas")

mapa1+mapa2
```

![](./Auxiliares/parcelas.png)

### 4.2. Extracción de métricas LiDAR de las parcelas

Las métricas de una nube de puntos LiDAR consisten en una serie de estadísticas que describen y resumen la distribución de las alturas y/o intensidades de los puntos que a ella pertenecen. 

![](./Auxiliares/metricas.png)

La librería *lidR* en R permite el cálculo una serie de estadísticos predefinidos en la nube de puntos. Pero además, aporta la enorme ventaja de su capacidad para definir nuevas estadísticas a través de líneas de código. Cualquier usuario puede crearlas en función de las características de la masa que se pretenda modelizar. Como ejemplo, se ha incluido una función para calcular métricas bastante utilizadas en el mundo forestal.

```r
#Definir métricas a extraer
library(moments)
metricas=function(z){
        n <- length(z)
        zmin <- min(z)
        zmean <- mean(z)
        zmax <- max(z)
        zsd <- sd(z)
        zskew <- skewness(z)
        zkurt <- kurtosis(z)
        zq25 <- quantile(z,prob=0.25)
        zq50 <- quantile(z,prob=0.50)
        zq60 <- quantile(z,prob=0.60)
        zq75<-quantile(z,prob=0.75)
        zq80<-quantile(z,prob=0.80)
        zq90<-quantile(z,prob=0.90)
        zpabovezmean<-round(length(which(z>zmean))/n*100,2)
        zpabovez2<-round(length(which(z>2))/n*100,2)
        metrics=list(n=n,
                     zmin=zmin,
                     zmean=zmean,
                     zmax=zmax,
                     zsd=zsd,
                     zskew=zskew,
                     zkurt=zkurt,
                     zq25=zq25,
                     zq50=zq50,
                     zq60=zq60,
                     zq75=zq75,
                     zq80=zq80,
                     zq90=zq90,
                     zpabovezmean=zpabovezmean,
                     zpabovez2=zpabovez2
                     )
        return(metrics)
}
```

Y posteriormente, se aplica la función definida por nosotros sobre los datos del catalogo LiDAR, conociendo las coordenadas de las parcelas y su radio, que es de 11 metros, como se observa en la columna *Radio* de la tabla de datos de campo.

```r
#Ejecutar la extracción de métricas de parcelas
metricas.parcelas<-plot_metrics(catalogo_norm,
                                ~metricas(Z),coord.parc,
                                radius=11)

metricas.parcelas
```

```r annotate
## Simple feature collection with 27 features and 17 fields
## Geometry type: POINT
## Dimension:     XY
## Bounding box:  xmin: 534750 ymin: 4118454 xmax: 537166.1 ymax: 4121237
## Projected CRS: WGS 84 / UTM zone 30N
## First 10 features:
##    ID Parcela    n   zmin    zmean   zmax      zsd       zskew    zkurt
## 1   1       1  144 -0.191 2.923757  9.410 3.268588  0.46609380 1.566404
## 2   2       2  204 -0.032 3.719201  8.737 3.114305 -0.21569186 1.281997
## 3   3       3  353 -0.065 3.091776 10.429 3.463975  0.49533538 1.622113
## 4   4       4  152 -0.072 2.127980  6.527 2.201560  0.34726012 1.552400
## 5   5       5  275  0.000 3.635869  9.283 3.333343  0.05467518 1.299853
## 6   6       6  322 -0.242 4.202984 10.574 3.597308 -0.18899969 1.253465
## 7   7       7  216 -0.221 4.842528 12.460 4.159956 -0.09964796 1.383319
## 8   8       8  127 -0.055 9.030512 16.891 5.879556 -0.61464270 1.821459
## 9   9       9  949 -0.934 4.776403 14.726 5.076684  0.25732807 1.358689
## 10 10      10 1184 -0.210 3.042573  8.385 2.540536 -0.03463205 1.420987
##        zq25    zq50    zq60     zq75    zq80    zq90 zpabovezmean zpabovez2
## 1   0.00000  0.4720  4.1244  6.01425  6.4426  7.7618        45.83     46.53
## 2   0.00000  5.2375  5.7302  6.42125  6.6620  7.0938        58.33     60.78
## 3   0.00000  0.2930  3.9592  6.46600  7.0558  8.1462        43.91     48.44
## 4   0.00000  2.0710  3.1992  4.13425  4.3982  4.9930        50.00     50.00
## 5   0.00000  4.4230  5.5990  6.77200  7.0300  7.9190        53.82     55.27
## 6   0.00000  6.1435  6.5456  7.28950  7.4842  8.1028        58.39     59.01
## 7   0.00000  6.5120  7.4010  8.23900  8.5730  9.7370        56.94     60.19
## 8   0.05650 11.1010 12.2496 13.57800 14.2812 15.1366        63.78     74.02
## 9  -0.15700  2.9930  7.4816  9.81000 10.5664 11.6532        48.16     51.84
## 10  0.17975  3.7800  4.4750  5.25450  5.5080  6.0960        56.08     60.30
##                    geometry
## 1    POINT (535750 4118454)
## 2    POINT (535350 4118554)
## 3    POINT (535050 4118654)
## 4    POINT (535350 4118754)
## 5    POINT (534750 4118654)
## 6  POINT (535349.3 4119656)
## 7  POINT (535355.6 4118945)
## 8  POINT (535842.8 4119051)
## 9    POINT (536150 4119154)
## 10   POINT (536750 4119154)
```

Como se observa, el resultado consiste en un shapefile de puntos con tantos registros como datos introducidos y cuya tabla asociada contiene las métricas de la nuble LiDAR en las parcelas.

```r
#Ver resultados
View(as.data.frame(metricas.parcelas))
```

ID | Parcela | n | zmin | zmean | zmax | zsd | zskew | zkurt | zq25 | zq50 | zq60 | zq75 | zq80 | zq90 | zpabovezmean | zpabovez2 | geometry
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---
1 | 1 | 144 | -0.191 | 2.923757 | 9.410 | 3.268588 | 0.4660938 | 1.566404 | 0.00000 | 0.4720 | 4.1244 | 6.01425 | 6.4426 | 7.7618 | 45.83 | 46.53 | POINT (535750 4118454)
2 | 2 | 204 | -0.032 | 3.719201 | 8.737 | 3.114305 | -0.2156919 | 1.281997 | 0.00000 | 5.2375 | 5.7302 | 6.42125 | 6.6620 | 7.0938 | 58.33 | 60.78 | POINT (535350 4118554)
3 | 3 | 353 | -0.065 | 3.091776 | 10.429 | 3.463975 | 0.4953354 | 1.622113 | 0.00000 | 0.2930 | 3.9592 | 6.46600 | 7.0558 | 8.1462 | 43.91 | 48.44 | POINT (535050 4118654)
4 | 4 | 152 | -0.072 | 2.127980 | 6.527 | 2.201560 | 0.3472601 | 1.552400 | 0.00000 | 2.0710 | 3.1992 | 4.13425 | 4.3982 | 4.9930 | 50.00 | 50.00 | POINT (535350 4118754)
5 | 5 | 275 | 0.000 | 3.635869 | 9.283 | 3.333343 | 0.0546752 | 1.299853 | 0.00000 | 4.4230 | 5.5990 | 6.77200 | 7.0300 | 7.9190 | 53.82 | 55.27 | POINT (534750 4118654)
6 | 6 | 322 | -0.242 | 4.202985 | 10.574 | 3.597308 | -0.1889997 | 1.253465 | 0.00000 | 6.1435 | 6.5456 | 7.28950 | 7.4842 | 8.1028 | 58.39 | 59.01 | POINT (535349.3 4119656)
7 | 7 | 216 | -0.221 | 4.842528 | 12.460 | 4.159956 | -0.0996480 | 1.383319 | 0.00000 | 6.5120 | 7.4010 | 8.23900 | 8.5730 | 9.7370 | 56.94 | 60.19 | POINT (535355.6 4118945)
8 | 8 | 127 | -0.055 | 9.030512 | 16.891 | 5.879556 | -0.6146427 | 1.821459 | 0.05650 | 11.1010 | 12.2496 | 13.57800 | 14.2812 | 15.1366 | 63.78 | 74.02 | POINT (535842.8 4119051)
9 | 9 | 949 | -0.934 | 4.776402 | 14.726 | 5.076684 | 0.2573281 | 1.358689 | -0.15700 | 2.9930 | 7.4816 | 9.81000 | 10.5664 | 11.6532 | 48.16 | 51.84 | POINT (536150 4119154)
10 | 10 | 1184 | -0.210 | 3.042573 | 8.385 | 2.540536 | -0.0346321 | 1.420987 | 0.17975 | 3.7800 | 4.4750 | 5.25450 | 5.5080 | 6.0960 | 56.08 | 60.30 | POINT (536750 4119154)
11 | 11 | 748 | -0.154 | 4.310402 | 9.888 | 3.230078 | -0.2512194 | 1.460595 | 0.39750 | 5.5025 | 6.0682 | 7.04125 | 7.3482 | 8.0897 | 60.29 | 64.57 | POINT (535775.8 4119217)
12 | 12 | 636 | -1.046 | 4.379083 | 10.200 | 3.687601 | -0.3245495 | 1.408023 | -0.15100 | 5.9290 | 6.6580 | 7.44925 | 7.7940 | 8.4210 | 61.64 | 64.15 | POINT (536250 4119254)
13 | 13 | 219 | -0.338 | 4.076247 | 10.436 | 3.789519 | -0.0311945 | 1.219511 | 0.00000 | 5.6370 | 6.4870 | 7.56650 | 7.8414 | 8.5152 | 54.79 | 55.71 | POINT (535953.6 4119854)
14 | 14 | 1288 | -0.124 | 3.123131 | 8.086 | 2.517762 | -0.1518637 | 1.332295 | 0.24200 | 4.1160 | 4.6804 | 5.28425 | 5.5144 | 5.9930 | 58.23 | 59.94 | POINT (535350 4119254)
15 | 15 | 253 | -0.075 | 2.202676 | 8.089 | 2.696216 | 0.6312236 | 1.734134 | 0.00000 | 0.0960 | 2.6680 | 4.66100 | 5.3998 | 6.2700 | 41.50 | 41.90 | POINT (535551.9 4119551)
17 | 17 | 973 | -0.778 | 3.636291 | 9.295 | 3.250584 | -0.2172299 | 1.341470 | -0.13800 | 5.0840 | 5.6572 | 6.44600 | 6.7434 | 7.3112 | 59.61 | 61.05 | POINT (535832.1 4119442)
19 | 19 | 182 | 0.000 | 2.539478 | 7.613 | 2.436899 | 0.2274244 | 1.527509 | 0.00000 | 2.7600 | 3.5696 | 4.80125 | 5.0422 | 5.6211 | 51.65 | 54.40 | POINT (536146.8 4119961)
20 | 20 | 344 | -0.162 | 3.340602 | 9.113 | 3.042132 | 0.0065676 | 1.315977 | 0.00000 | 4.5365 | 5.3136 | 6.00000 | 6.2712 | 6.9967 | 54.65 | 56.10 | POINT (535550 4119754)
22 | 22 | 252 | 0.000 | 5.267294 | 11.989 | 4.275847 | -0.2205838 | 1.346517 | 0.00000 | 6.9810 | 8.0558 | 8.87800 | 9.2620 | 10.1436 | 58.33 | 62.70 | POINT (536850 4120054)
23 | 23 | 238 | -0.119 | 5.677706 | 11.009 | 4.075608 | -0.5861394 | 1.509746 | 0.00000 | 7.8875 | 8.2462 | 8.84100 | 8.9986 | 9.5375 | 65.55 | 67.23 | POINT (535750 4120054)
21 | 21 | 248 | -0.282 | 3.095867 | 9.478 | 3.027750 | 0.2350487 | 1.428990 | 0.00000 | 3.2025 | 4.4820 | 5.92500 | 6.4574 | 7.1041 | 50.40 | 53.23 | POINT (536350 4120054)
25 | 25 | 250 | -0.091 | 5.678732 | 12.471 | 4.480034 | -0.2634613 | 1.354276 | 0.00000 | 7.4740 | 8.6360 | 9.54900 | 9.9506 | 10.6841 | 58.40 | 65.20 | POINT (536849.2 4120257)
27 | 27 | 204 | -0.230 | 3.936181 | 9.604 | 2.940838 | -0.2960101 | 1.555978 | 0.00000 | 4.9800 | 5.5200 | 6.31175 | 6.6996 | 7.2727 | 59.31 | 67.16 | POINT (537166.1 4121150)
28 | 28 | 170 | -0.298 | 11.277694 | 21.323 | 6.500379 | -0.4875670 | 1.870323 | 5.41425 | 13.7210 | 14.7012 | 16.71275 | 17.0700 | 18.5512 | 58.82 | 85.88 | POINT (536855.7 4121123)
29 | 29 | 190 | 0.000 | 12.130379 | 18.495 | 5.335021 | -1.5152373 | 3.947334 | 11.76325 | 13.9845 | 14.5300 | 15.47425 | 15.7718 | 16.5263 | 71.58 | 85.79 | POINT (537039.8 4121237)
30 | 30 | 264 | -0.284 | 4.149523 | 10.040 | 3.861291 | -0.0408131 | 1.178377 | 0.00000 | 5.7985 | 6.8646 | 7.87925 | 8.0740 | 8.6989 | 54.92 | 54.92 | POINT (536950.8 4119754)
31 | 31 | 920 | -0.186 | 3.186741 | 8.393 | 2.688232 | -0.1099419 | 1.308814 | 0.13675 | 4.2870 | 4.8738 | 5.55875 | 5.7694 | 6.2943 | 57.39 | 58.59 | POINT (536839.2 4119197)

### 4.3. Modelización de las variables

Un modelo lineal o regresión lineal se utiliza para predecir el resultado de una variable *y*, sobre la base de una o varias variables predictoras *x*. El objetivo consiste en construir una fórmula matemática que defina el comportamiento de la variable *y* en función de la variable *x*. 

$$y = b_{0} + b_{1}·x$$

Después de construir el modelo, estadísticamente significativo, es posible usarlo para predecir resultados con nuevos valores de la variable *x*.

En los inventarios LiDAR, la variable *y* será cualquiera de las variables dasométricas medidas en campo, por ejemplo, altura dominante, área basimétrica, volumen de madera, biomasa, etc... La variable *x* será una variable conocida de la que se tiene toda la información de forma continua en todo el área de estudio, una métrica LiDAR. A través de dicha métrica se predecirá la variable de campo de forma continua en toda la superficie.

```r
#Unir tablas
parcelas<-merge(campo,metricas.parcelas)
```

#### 4.3.1. Estudio de la variable respuesta área basimétrica G (m2/ha)

Primero se va a comprobar la distribución de la variable respuesta. El tipo de modelos que se están empleando necesitan que siga una distribución normal. Para comprobarlo, se va a visualizar el histograma de distribución que sigue la variable, un gráfico cualtil-cuantil o qqplot que compara la distribución de la variable con la distribución normal teórica y finalmente se ejecuta un test de normalidad con la prueba de Shapiro-Wilks.

```r
#Nombres de los campos de la tabla
names(parcelas)
```

```r annotate
##  [1] "Parcela"      "Radio"        "N_pies_ha"    "G_m2_ha"      "Dg_cm"       
##  [6] "dmedio_cm"    "Ho_Assman_m"  "hmedia_m"     "ID"           "n"           
## [11] "zmin"         "zmean"        "zmax"         "zsd"          "zskew"       
## [16] "zkurt"        "zq25"         "zq50"         "zq60"         "zq75"        
## [21] "zq80"         "zq90"         "zpabovezmean" "zpabovez2"    "geometry"
```

```r
#Histograma de frecuencias
hist(parcelas$G_m2_ha,freq=FALSE)
lines(density(parcelas$G_m2_ha))
```

![](./Auxiliares/histograma_g.png)

```r
#Gráfico cuantil-cuantil
qqnorm(parcelas$G_m2_ha)
qqline(parcelas$G_m2_ha)
```

![](./Auxiliares/qq.png)

```r
#Prueba de Shapiro-Wilks
shapiro.test(parcelas$G_m2_ha) 
```

```r annotate
## 
##  Shapiro-Wilk normality test
## 
## data:  parcelas$G_m2_ha
## W = 0.94102, p-value = 0.1291
```

Como el *p-valor* del resultado de la prueba de Shapiro-Wilks es superior a 0.05, no se rechaza la hipótesis nula, es decir, que la distribución de la variable de área basimétrica se considera normal. 

```r
library (car)

#Gráfico de cajas y bigotes
Boxplot(parcelas$G_m2_ha)
```

```r annotate
## [1] 25
```

![](./Auxiliares/boxplot.png)

Existe un outlier o valor atípico en la parcela 25. Puede ser un error de la medición en campo o de la introducción de datos. Como desconocemos cuál es la causa real y desconocemos si es posible corregirlo, se elimina la parcela, que no formará parte del modelo.

```r
#Eliminar outlier
parcelas.o<-parcelas[-c(25),]
```

Ahora, se comprueba que este valor atípico no influye en la distribución normal de la variable.

```r
#Estudio normalidad
shapiro.test(parcelas.o$G_m2_ha)
```

```r annotate
## 
##  Shapiro-Wilk normality test
## 
## data:  parcelas.o$G_m2_ha
## W = 0.95011, p-value = 0.2333
```

El *p-valor* resultante del test continua siendo superior a 0.05.

Seguidamente, se realiza un estudio de normalidad para las métricas LiDAR predictoras. Sólo las cumplan con este riquisito podrán usarse en el modelo lineal. Se emplea para ello un bucle que va a repetir la prueba de Shapiro-Wilks a todos los campos que contienen variables LiDAR, entre el número de columna 10 y el 24, e imprime en pantalla sólo el resultado de las variables normales.

```r
for (i in 10:24){
        a<-shapiro.test(parcelas.o[,i])
        if (a$p.value>0.05){
                print(paste0(colnames(parcelas.o)[i],"->",a$p.value))
        }
}
```

```r annotate
## [1] "zskew->0.467304417253028"
## [1] "zkurt->0.0622810435575442"
## [1] "zq50->0.0898344423406685"
## [1] "zpabovezmean->0.155392876207957"
## [1] "zpabovez2->0.263918639516189"
```

Todas estas variables serán las que se utilicen en el modelo. Para determinar la mejor relación bivariante entre el área basimétrica y el resto de variables predictoras LiDAR, primero se va a determinar qué variables tienen una correlación estadísticamente significativa, esto es, con *p-valor* inferior a 0.05.

```r
library(Hmisc)

#Generación de matrices de correlaciones
correlaciones<-rcorr(as.matrix(parcelas.o[,c("G_m2_ha",
                                           "zskew",
                                           "zkurt",
                                           "zq50",
                                           "zpabovezmean",
                                           "zpabovez2")]),
                     type="pearson")

pp<-as.data.frame(correlaciones$P)
rr<-as.data.frame(correlaciones$r)

names(pp[which(pp$G_m2_ha<0.05)])
```

```r annotate
## [1] "zskew"        "zq50"         "zpabovezmean" "zpabovez2"
```

Y, a continuación, se visualizan las correlaciones entre las variables LiDAR y el área basimétrica.

```r
#Ver resultados
View(rr)
```

Var | G_m2_ha | zskew | zkurt | zq50 | zpabovezmean | zpabovez2
 --- | --- | --- | --- | --- | --- | ---
G_m2_ha | 1.0000000 | -0.8314934 | 0.0987390 | 0.9193272 | 0.7379081 | 0.8226766
zskew | -0.8314934 | 1.0000000 | 0.0257963 | -0.8804376 | -0.9734431 | -0.9040074
zkurt | 0.0987390 | 0.0257963 | 1.0000000 | 0.1722931 | -0.1534406 | 0.2689428
zq50 | 0.9193272 | -0.8804376 | 0.1722931 | 1.0000000 | 0.7788641 | 0.9319718
zpabovezmean | 0.7379081 | -0.9734431 | -0.1534406 | 0.7788641 | 1.0000000 | 0.8161738
zpabovez2 | 0.8226766 | -0.9040074 | 0.2689428 | 0.9319718 | 0.8161738 | 1.0000000

La variable explicativa LiDAR con la correlación estadísticamente significativa más alta con el área basimétrica medida en campo es el percentil 50 de las alturas de los puntos, *zq50*. Será esta métrica la que se emplee para crear el modelo.

Es importante analizar qué tipo de variable se va a emplear en el modelo para que éste tenga un sentido físico y no sea un artificio matemático que no aporte una explicación a la interacción entre la variable respuesta y predictora. En este ejemplo, al modelizar el área basimétrica, una variable que tiene que ver con la cantidad y el tamaño de los diámetros medidos a la altura del pecho, es lógico que muestre sensiblilidad a la distribución de los puntos centrales de la nube LiDAR.

```r
#Generar modelo lineal
modelo.G<-lm(G_m2_ha~zq50,data=parcelas.o)
summary(modelo.G)
```

```r annotate
## 
## Call:
## lm(formula = G_m2_ha ~ zq50, data = parcelas.o)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -8.2323 -1.0048  0.3196  1.6915  5.6732 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  10.9512     1.2448   8.797 5.64e-09 ***
## zq50          2.4372     0.2129  11.446 3.31e-11 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 3.218 on 24 degrees of freedom
## Multiple R-squared:  0.8452, Adjusted R-squared:  0.8387 
## F-statistic:   131 on 1 and 24 DF,  p-value: 3.306e-11
```

Fijándonos en los resultados del modelo, en el valor de *Estimate* se obtendrá la estimación del parámetro $b_{0}$ y del $b_{1}$ de la ecuación lineal, que quedaría así:

$$G=10.9512+2.4372·zq50$$

#### Bondad del ajuste

Cuando se crea un modelo de regresión, se necesita evaluar el rendimiento predictivo del modelo, es decir, qué tan bien predice el resultado. Para ello se suelen usar las siguientes estadísticas:

```r
#Residuos del modelo
residuos<-modelo.G$fitted.values-parcelas.o$G_m2_ha
residuos
```

```r annotate
##           1           2           3           4           5           6 
## -1.71352196  0.39661607 -2.95295059  4.95062133 -5.67317561  0.02934902 
##           7           8           9          10          11          12 
## -4.06589366 -1.21215103 -0.67379562  8.23226486 -4.26232666 -0.76207056 
##          13          14          15          16          17          18 
## -0.28465318  0.26226050 -0.21189263 -2.46115493  1.96594842 -1.62538066 
##          19          20          21          22          23          24 
##  5.76720643 -0.35459661 -1.12147530  3.40566849  0.44982711  3.01868003 
##          26          27 
## -2.29323660  1.18983334
```

```r
#Residual sum of squares
RSS <- c(crossprod(residuos))
RSS
```

```r annotate
## [1] 248.4719
```

```r
#Mean squared error 
MSE <- RSS / length(modelo.G$fitted.values)
MSE
```

```r annotate
## [1] 9.556611
```

```r
#Root mean squared error
RMSE <- sqrt(MSE)
RMSE
```

```r annotate
## [1] 3.091377
```

```r
#Total sum of squares
TSS <- sum((parcelas.o$G_m2_ha - mean(parcelas.o$G_m2_ha)) ^ 2) 
TSS
```

```r annotate
## [1] 1604.727
```

```r
#R cuadrado
RSQ<-1-(RSS/TSS)
RSQ
```

```r annotate
## [1] 0.8451626
```

#### Gráfico predicho vs observado

Este gráfico muestra de forma muy descriptiva la dispersión respecto de la recta de la ecuación lineal para cada valor predicho, es decir, cuánto se alejan del ajuste calculado. Se espera no observar ningún tipo de patrón en los residuos y no ver datos atípicos que significarían datos con residuos muy grandes.

```r
#correlaciones predicho vs observado
correlaciones<-round(cor(modelo.G$fitted.values,
                         parcelas.o$G_m2_ha),3)

#Gráfico predicho vs observado
plot(parcelas.o$G_m2_ha, predict(modelo.G),
     xlab=as.expression(bquote("Área basimétrica observada ("~m^2~"/ha)")),
     ylab=as.expression(bquote("Área basimétrica predicha ("~m^2~"/ha)")))
abline(0,1) 
legend("topleft",legend=c(paste0("r=",round(correlaciones,2)),
                          as.expression(bquote(R^2 ==.(round(RSQ,2)))),
                          paste0("RMSE=",round(RMSE,2))),
       bty = "n")
```

![](./Auxiliares/predicho_observado.png)

Finalmente, se da por bueno el modelo generado. 

## 5. Extracción de métricas de superficie y resultados de variables de inventario

### 5.1. Calculo del tamaño de pixel

Una de los puntos clave de la extrapolacion de los resultados del modelo a toda la superficie es la decision del tamaño de pixel del raster que va a representar la variable calculada. Generalmente, se establece que el tamaño de celda debe ser equivalente al de tamaño de la parcela medida en campo para que los parametros estadisticos sean coherentes.

Por eso, si el radio de las parcelas era de 11 metros.

```r
#Superficie de la parcela
R=11
Tamano.parcela<-(R^2)*pi

#Lado del pixel
tamano.lado.pixel<-round(sqrt(Tamano.parcela),0)
tamano.lado.pixel
```

```r annotate
## [1] 19
```

El tamaño de celda sera, por tanto, de 19 m.

### 5.3. Extraccion de las metricas de superficies

Si para computar las metricas a nivel de parcela se empleaba la funcion *plot_metrics()*, para hacerlo a nivel de superficies se utiliza la funcion *grid_metrics()*, que calcula las estadisticas que se han definido en el ejercicio anterior para el conjunto de datos LiDAR dentro de cada pixel de un raster. En el parametro *res* se indica el tamaño de celda de 19 m.

```r
#Activacion de las librerias necesarias
library(lidR)
library(moments)

#Calculo de metricas en toda la superficie
metricas.superf <- grid_metrics(catalogo_norm,
                                ~metricas(Z), res = 19)
metricas.superf
```

```r annotate
## class      : RasterBrick 
## dimensions : 212, 211, 44732, 15  (nrow, ncol, ncell, nlayers)
## resolution : 19, 19  (x, y)
## extent     : 533995, 538004, 4117984, 4122012  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      :          n,       zmin,      zmean,       zmax,        zsd,      zskew,      zkurt,       zq25,       zq50,       zq60,       zq75,       zq80,       zq90, zpabovezmean,  zpabovez2 
## min values :  17.000000, -22.684000,  -1.419597,   0.000000,   0.000000,  -2.548080,   1.101600,  -1.948000,  -1.410000,  -1.260800,  -1.032750,  -0.947000,  -0.715600,     0.000000,   0.000000 
## max values : 5502.00000,    0.00000,   16.43545,  280.16400,   13.47157,   19.48124,  401.31393,   16.60000,   19.65100,   20.23920,   21.66200,   22.70220,   24.43440,     82.97000,   94.39000
```

El resultado consiste en un objeto multicapa raster con la resolucion de 19 m y con la misma extension y sistema de referencia que los datos LiDAR descargados. Cada una de las capas corresponde a cada metrica definida en la funcion *metricas* creada en el ejercicio anterior.

```r
#Capas de metricas
names(metricas.superf)
```

```r annotate
##  [1] "n"            "zmin"         "zmean"        "zmax"         "zsd"         
##  [6] "zskew"        "zkurt"        "zq25"         "zq50"         "zq60"        
## [11] "zq75"         "zq80"         "zq90"         "zpabovezmean" "zpabovez2"
```

Y tambien se pueden visualizar geograficamente.

```r
#Capas de percentil 50
plot(metricas.superf$zq50)
```

![](./Auxiliares/zq50.png)

### 5.4. Resultados de variables de inventario

#### 5.4.1. Con la funcion *predict()*

La funcion *predict()* se utiliza para predecir resultados de un modelo sobre nuevos valores. En este ejemplo, los nuevos valores corresponden al raster de percentil 50 de toda la superficie de estudio.

```r
#Aplicar la prediccion del modeloal raster de percentil 50
G.predict<-predict(metricas.superf$zq50,modelo.G)
G.predict
```

```r annotate
## class      : RasterLayer 
## dimensions : 212, 211, 44732  (nrow, ncol, ncell)
## resolution : 19, 19  (x, y)
## extent     : 533995, 538004, 4117984, 4122012  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : layer 
## values     : 7.514767, 58.84476  (min, max)
```

El resultado consiste en una capa raster cuyos valores corresponden directamente a valores de area basimetrica expresados en $m^{2}/ha$, que es la misma unidad de medida con la que se introdujeron los valores desde la tabla de datos de campo al modelo.

```r
#Visualizar raster de area basimetrica
library(mapview())
mapview(G.predict,layer.name = "area basimetrica",
        map.type = "Esri.WorldImagery")
```

![](./Auxiliares/G.png)

#### 5.4.2. Aplicando la ecuacion de la regresion lineal

El resultado del modelo lineal simple que se ha cread es una ecuacion lineal. Se pueden conocer cual es la estimacion del parametro $b_{0}$ y del $b_{1}$ llamando a los coeficientes del modelo

```r
#Coeficientes del modelo modelo lineal
modelo.G$coefficients
```

```r annotate
## (Intercept)        zq50 
##   10.951227    2.437206
```

Y calcular el modelo siguiendo dicha ecuacion.

```r
#Coeficientes del modelo modelo lineal
G.predict2<-modelo.G$coefficients[1] +
        modelo.G$coefficients[2]*metricas.superf$zq50
G.predict2
```

```r annotate
## class      : RasterLayer 
## dimensions : 212, 211, 44732  (nrow, ncol, ncell)
## resolution : 19, 19  (x, y)
## extent     : 533995, 538004, 4117984, 4122012  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : zq50 
## values     : 7.514767, 58.84476  (min, max)
```

El resultado sigue siendo un raster cuyos valores corresponden a la estimacion segun el modelo en cada unidad de celda del area basimetrica expresados en $m^{2}/ha$.

Y su representacion cartografica es exactamente igual a la anterior.

```r
#Visualizar raster de area basimetrica
mapview(G.predict2,layer.name = "area basimetrica",
        map.type = "Esri.WorldImagery")
```

![](./Auxiliares/G.png)

### 5.5. Guardar resultados

Finalmente, se guardan los resultados para poder emplearlo en un programa de sistema de informacion geografica como ArcGIS o QGIS.

```r
#Guardar raster
writeRaster(G.predict,
            filename="E:/DESCARGA/G.tif",                    #Adaptar a la ruta deseada
            format = "GTiff", # guarda como geotiff
            datatype='FLT4S') # guarda en valores decimales
```
