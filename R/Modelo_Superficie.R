#Superficie de la parcela
R=11
Tamano.parcela<-(R^2)*pi

#Lado del pixel
tamano.lado.pixel<-round(sqrt(Tamano.parcela),0)
tamano.lado.pixel

#Activacion de las librerias necesarias
library(lidR)
library(moments)

#Calculo de metricas en toda la superficie
metricas.superf <- grid_metrics(catalogo_norm,
                                ~metricas(Z), res = 19)
metricas.superf

#Capas de metricas
names(metricas.superf)

#Capas de percentil 50
plot(metricas.superf$zq50)

#Aplicar la prediccion del modeloal raster de percentil 50
G.predict<-predict(metricas.superf$zq50,modelo.G)
G.predict

#Visualizar raster de area basimetrica
library(mapview())
mapview(G.predict,layer.name = "area basimetrica",
        map.type = "Esri.WorldImagery")

#Coeficientes del modelo modelo lineal
modelo.G$coefficients

#Coeficientes del modelo modelo lineal
G.predict2<-modelo.G$coefficients[1] +
  modelo.G$coefficients[2]*metricas.superf$zq50
G.predict2

#Visualizar raster de area basimetrica
mapview(G.predict2,layer.name = "area basimetrica",
        map.type = "Esri.WorldImagery")

#Guardar raster
writeRaster(G.predict,
            filename="E:/DESCARGA/G.tif",                    #Adaptar a la ruta deseada
            format = "GTiff", # guarda como geotiff
            datatype='FLT4S') # guarda en valores decimales