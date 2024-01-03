#Densidad media de puntos clasificados como suelo
density(lidar534_4120[which(lidar534_4120@data$Classification==2),])

#Separación media entre puntos clasificados como suelo
1/sqrt(density(lidar534_4120[which(lidar534_4120@data$Classification==2),]))

#Evaluación de la distribución espacial de puntos clasificados como suelo
densidad_suelo<-grid_density(lidar534_4120[which(lidar534_4120@data$Classification==2),], res = 5)
densidad_suelo

#Visualización de la distribución espacial de la densidad de los puntos de suelo
library(mapview)
mapview(densidad_suelo[[1]],
        col.regions = c("red","green","darkgreen","yellow","orange","red","brown"),
        at = c(0,0.05,0.1,0.2,0.3,0.4,0.5,2))

#Separación entre pulsos
1/sqrt(0.05)

mdt <- grid_terrain(lidar534_4120, res = 5, algorithm=tin())

mdt

mapview(mdt,col = terrain.colors(50),maxpixels=1000000,
        map.type = "Esri.WorldImagery")

#Cálculo de la pendiente del terreno en radianes
pendiente_rad <- terrain(mdt, opt='slope')

#Cálculo de la pendiente del terreno en grados
pendiente_grados <- terrain(mdt, opt='slope',unit="degrees")

#Visualización de los resultados
mapview(pendiente_grados,col = terrain.colors(50),maxpixels=1000000,
        map.type = "Esri.WorldImagery")

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

#Visualizar orientaciones
mapview(orientacion_reclas,
        col.regions = c("red","orange","yellow","green",
                        "cyan","deepskyblue2","blue","deeppink"),
        maxpixels=1000000, map.type = "Esri.WorldImagery")

sombras <- hillShade(pendiente_rad, orientacion_rad, angle=45, direction=315)

mapview(sombras,col.regions=hcl.colors(255,"Gray"),maxpixels=1000000,
        map.type = "Esri.WorldImagery")

lidar534_4120.mas.altos<-decimate_points(lidar534_4120, highest(res=5))

mds<-grid_canopy(lidar534_4120.mas.altos,res=5,dsmtin(max_edge=0))

mds

mapview(mds,col.regions=hcl.colors(255,"Gray"),maxpixels=1000000)

nmds1<-mds-mdt

nmds1

hist(nmds1,breaks=250,xlim=c(-2.5,0))

mapview(nmds1,col.regions=rev(hcl.colors(17,"Spectral")),
        at = c(-Inf,0,1,2,3,4,5,6,7,8,9,10,11,13,14,15),maxpixels=1000000)

archivo_norm<-normalize_height(lidar534_4120, tin())

recorte_norm<-clip_rectangle(archivo_norm,
                             min(archivo_norm$X)+1850,
                             min(archivo_norm$Y)+1170,
                             min(archivo_norm$X)+2000,
                             min(archivo_norm$Y)+1320)

plot(recorte_norm,bg = "white", axis = TRUE, 
     legend = TRUE,size = 3)

nmds2<-grid_canopy(archivo_norm,res=2,dsmtin(max_edge=0))

nmds2

mapview(nmds2,col.regions=rev(hcl.colors(17,"Spectral")),
        at = c(-Inf,0,1,2,3,4,5,6,7,8,9,10,11,13,14,15),
        maxpixels=1000000)