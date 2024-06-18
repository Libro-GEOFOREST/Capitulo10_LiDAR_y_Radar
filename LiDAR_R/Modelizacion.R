library(lidR)

#Introducir los archivos LiDAR como un catalogo de datos
catalogo_norm<-readLAScatalog(folder="E:/DESCARGA/",     #Adaptar a la ruta de descarga utilizada
                              pattern = "norm.las")

library(readxl)

#Leer archivo con datos de campo
campo<-read_excel("E:/DESCARGA/DatosTrabajodeCampo/resultado parcelas.xls")  #Adaptar a la ruta de descarga utilizada

#Convertir la tabla en un data frame
campo<-as.data.frame(campo)

#Ver la tabla de datos
View(campo)

#Introducir coordenadas de las parcelas
library(sf)

coord.parc<-st_read("E:/DESCARGA/DatosTrabajodeCampo/coordenadas_parcelas.shp")  #Adaptar a la ruta de descarga utilizada

#Ver la tabla de datos
View(as.data.frame(coord.parc))

#Representación cartográfica de las parcelas
library(mapview)

mapa1<-mapview(catalogo_norm, alpha.regions = 0, color = "red", 
               lwd = 2, layer.name = "Datos LiDAR",
               map.type = "Esri.WorldImagery",legend=FALSE)

mapa2<-mapview(coord.parc,zcol="Parcela", layer.name="Parcelas")

mapa1+mapa2

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

#Ejecutar la extracción de métricas de parcelas
metricas.parcelas<-plot_metrics(catalogo_norm,
                                ~metricas(Z),coord.parc,
                                radius=11)

metricas.parcelas

#Ver resultados
View(as.data.frame(metricas.parcelas))

#Unir tablas
parcelas<-merge(campo,metricas.parcelas)

#Nombres de los campos de la tabla
names(parcelas)

#Histograma de frecuencias
hist(parcelas$G_m2_ha,freq=FALSE)
lines(density(parcelas$G_m2_ha))

#Gráfico cuantil-cuantil
qqnorm(parcelas$G_m2_ha)
qqline(parcelas$G_m2_ha)

#Prueba de Shapiro-Wilks
shapiro.test(parcelas$G_m2_ha) 

library (car)

#Gráfico de cajas y bigotes
Boxplot(parcelas$G_m2_ha)

#Eliminar outlier
parcelas.o<-parcelas[-c(25),]

#Estudio normalidad
shapiro.test(parcelas.o$G_m2_ha)

for (i in 10:24){
  a<-shapiro.test(parcelas.o[,i])
  if (a$p.value>0.05){
    print(paste0(colnames(parcelas.o)[i],"->",a$p.value))
  }
}

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

#Ver resultados
View(rr)

#Generar modelo lineal
modelo.G<-lm(G_m2_ha~zq50,data=parcelas.o)
summary(modelo.G)

#Residuos del modelo
residuos<-modelo.G$fitted.values-parcelas.o$G_m2_ha
residuos

#Residual sum of squares
RSS <- c(crossprod(residuos))
RSS

#Mean squared error 
MSE <- RSS / length(modelo.G$fitted.values)
MSE

#Root mean squared error
RMSE <- sqrt(MSE)
RMSE

#Total sum of squares
TSS <- sum((parcelas.o$G_m2_ha - mean(parcelas.o$G_m2_ha)) ^ 2) 
TSS

#R cuadrado
RSQ<-1-(RSS/TSS)
RSQ

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