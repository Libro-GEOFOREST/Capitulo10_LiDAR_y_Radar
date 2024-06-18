library(lidR)

catalogo<-readLAScatalog("E:/DESCARGA") #Adaptar a la ruta de descarga utilizada
catalogo 

#Ver la cabecera de los datos
catalogo@data

#Validar los datos LiDAR
las_check(catalogo)

#Valores de offset de los archivos del catalogo. Coordenada X
catalogo@data$X.offset

#Valores de offset de los archivos del catalogo. Coordenada Y
catalogo@data$Y.offset

#Valores de offset de los archivos del catalogo. Coordenada Z
catalogo@data$Z.offset

#Valores mínimos de los archivos del catalogo. Coordenada X
catalogo@data$Min.X

#Valores máximos de los archivos del catalogo. Coordenada X
catalogo@data$Max.X

#Valores mínimos de los archivos del catalogo. Coordenada Y
catalogo@data$Min.Y

#Valores máximos de los archivos del catalogo. Coordenada Y
catalogo@data$Max.Y

#Valores mínimos de los archivos del catalogo. Coordenada Z
catalogo@data$Min.Z

#Valores máximos de los archivos del catalogo. Coordenada Z
catalogo@data$Max.Z

#Corregir la cabecera
catalogo@data$X.offset<-c(0,0,0,0)
catalogo@data$Y.offset<-c(0,0,0,0)

#Volvemos a comprobar la validacion de los datos
las_check(catalogo)#Ya está corregido

lidar534_4120<-readLAS("E:/DESCARGA/PNOA_2014_AND-SE_534-4120_ORT-CLA-CIR.laz") #Adaptar a la ruta de descarga utilizada

#Vamos a ver el interior de los datos. Sólo los 6 primeros
head(lidar534_4120@data)

#Visualizar el catalogo sobre un mapa
#Necesita tener instalada la libreria mapview
#En caso de no tenerla instalada ejecutar la función install.packages()
#install.packages("mapview")
library(mapview)
plot(catalogo, map = TRUE, map.type = "Esri.WorldImagery")

#Visualizar en 3D
recorte<-clip_rectangle(lidar534_4120, 
                        min(lidar534_4120$X)+1850, 
                        min(lidar534_4120$Y)+1170, 
                        min(lidar534_4120$X)+2000,  
                        min(lidar534_4120$Y)+1320)

plot(recorte)

plot(recorte,bg = "white", axis = TRUE, legend = TRUE)

#Nombre de los archivos del catalogo
catalogo@data$filename

#Coordenada X mínima del recorte
catalogo@data$Min.X[1]+1850

#Coordenada Y mínima del recorte
catalogo@data$Min.Y[1]+1170

#Coordenada X máxima del recorte
catalogo@data$Min.X[1]+2000

#Coordenada Y máxima del recorte
catalogo@data$Min.Y[1]+1320

#Visualizar recorte del catalogo
recorte_catalogo<-readLAS((catalogo[[34]][1]),select = "xyz",
                          filter="-keep_xy 535850 4119170 536000 4119320")

plot(recorte_catalogo)

lidar534_4120 <- retrieve_pulses(lidar534_4120)

densidad<-grid_density(lidar534_4120, res = 5)
densidad

#Caracterizacion del raster como de valores discretos
library(raster)
densidad[[2]] <- ratify(densidad[[2]])

library(mapview)
mapview(densidad[[2]],
        col.regions = c("red","green","darkgreen","yellow","orange","red","brown"),
        at = c(0,0.3,1,2,3,4,5))

densidad_catalogo<-grid_density(catalogo, res = 5)
densidad_catalogo

mapview(densidad_catalogo,
        col.regions = c("red","green","darkgreen","yellow","orange","red","brown"),
        at = c(0,0.3,1,2,3,4,5))

table(lidar534_4120@data$Classification)

plot(recorte,color="Classification",axis = TRUE, legend = TRUE)

#Ver puntos clasificados como suelo
plot(recorte[which(recorte$Classification==2),],
     color="Classification",axis = TRUE)

summary(lidar534_4120@data$ScanAngleRank)

#Ver puntos según su ángulo de escaneo
plot(recorte,color="ScanAngleRank",axis = TRUE)

#Ver puntos clasificados como solape
plot(recorte[which(recorte$Classification==12),],
     color="Classification",axis = TRUE)

solape <- grid_metrics(lidar534_4120,
                       ~max(Classification), 
                       filter=~Classification == 12, res=5)
solape

mapview(solape)

table(lidar534_4120@data$PointSourceID)

lidar534_4120<-retrieve_flightlines(lidar534_4120, dt = 30)
plot(lidar534_4120, color = "flightlineID")

#Estimación de la posición del sensor con un archivo
lineas_vuelo <- track_sensor(lidar534_4120, 
                             Roussel2020(pmin = 15))
lineas_vuelo

x<-plot(lidar534_4120)
add_flightlines3d(x, lineas_vuelo, radius = 10)

#Estimación de la posición del sensor para un catálogo
lineas_vuelo_catalogo <- track_sensor(catalogo, 
                                      Roussel2020(pmin = 15))
plot(catalogo)
plot(lineas_vuelo_catalogo, add = TRUE)

#Ver puntos según su intensidad
plot(recorte,color="Intensity",
     colorPalette=gray.colors(10, start = 0, end = 1))

#Generar raster de intensidades
intensidad <- grid_metrics(lidar534_4120,
                           ~mean(Intensity), 
                           filter=~ReturnNumber == 1, res=5)

intensidad

library(mapview)
mapview(intensidad, 
        col.regions=gray.colors(255, start = 0, end = 1),na.color="red", map.type = "Esri.WorldImagery")

