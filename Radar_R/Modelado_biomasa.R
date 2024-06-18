pck <- c("tidyr", "dplyr", "readxl", "ggplot2", "randomForest", "car", "Metrics", "raster", "rasterVis", "rgdal", "mapview", "RColorBrewer", "ggplot2", "sf", "glcm", "ggpubr", "sf", "corrplot", "caret", "usdm")
sapply(pck, require, character.only=TRUE)

getwd()

alos2 <- stack(list.files(path="D:/cap_Radar/ALOS_15_SPK",full.names=TRUE))
plot(alos2)
names(alos2)

alos2_Gamma_dB <- 10 * log10 (alos2^2) - 83.0 
plot(alos2_Gamma_dB )

alos2_Gamma_pw <-  10^(0.1*alos2_Gamma_dB)
names(alos2_Gamma_pw)

plot(alos2_Gamma_pw)

S1_2015 <- stack(list.files(path="D:/cap_Radar/S1_2015_SPK",full.names=TRUE))

names(S1_2015) <- c("vhAscDesc_2015", "vhAsc_2015","vhDesc_2015" ,"vvAscDesc_2015", "vvAsc_2015","vvDesc_2015")


#resampleamos al tamaño de pixel de las imagenes ALOS2
S1_2015 <- resample(S1_2015, alos2_Gamma_pw)

plot(S1_2015)

S1_2015_Gamma_pw <-  10^(0.1*S1_2015)

plot(S1_2015_Gamma_pw)

names_S1_2015 <- names(S1_2015_Gamma_pw)

LANDSAT <- stack(list.files(path="D:/cap_Radar/LANDSAT_2015",full.names=TRUE))

LANDSAT <- resample(LANDSAT, alos2_Gamma_pw)

plot(LANDSAT)

getwd()

parcelas <- st_read("D:/cap_Radar/inventario_biomasa_wgs84/inventario_biomasa_wgs84.shp")

plot(parcelas[3])

names(parcelas)

# Estudio previo de los datos
# Se carga la librería 'car' para usar algunas funciones útiles.
library(car)

# Se imprime un resumen estadístico de la variable 'Ctt_MC.' en el dataframe 'parcelas'.
summary(parcelas$Ctt_MC.)

# Se crea un diagrama de caja (boxplot) para visualizar la distribución de la variable 'Ctt_MC.' en 'parcelas'.
Boxplot(parcelas$Ctt_MC.)

# Se identifican los valores atípicos (outliers) de la variable 'Ctt_MC.' utilizando boxplot.
outliners <- boxplot(parcelas$Ctt_MC.)$out

outliners

# Se filtran los datos para mantener solo aquellos cuyo valor en 'Ctt_MC.' sea menor o igual a 127.2519.
parcelas <- subset.data.frame(parcelas, parcelas$Ctt_MC. <= 120 )

# Se imprime un resumen estadístico de 'Ctt_MC.' después de filtrar los valores.
summary(parcelas$Ctt_MC.)

# Se crea un nuevo boxplot para visualizar la distribución actualizada de 'Ctt_MC.'.
Boxplot(parcelas$Ctt_MC.)

# Se imprime un resumen estadístico adicional de 'Ctt_MC.' después del filtrado.
summary(parcelas$Ctt_MC.)

# Se crea un histograma para visualizar la distribución de 'Ctt_MC.' después del filtrado.
hist(parcelas$Ctt_MC.)

# Se identifican los índices de las observaciones cuyo valor en 'Ctt_MC.' es igual a cero.
which(parcelas$Ctt_MC. == 0)

# Se eliminan las observaciones donde 'Ctt_MC.' es igual a cero del dataframe 'parcelas'.
parcelas <- parcelas[-which(parcelas$Ctt_MC. == 0),]

# Se crea otro histograma para visualizar la distribución de 'Ctt_MC.' después de eliminar los valores iguales a cero.
hist(parcelas$Ctt_MC.)

# Cargar el DEM
DEM <- raster("D:/cap_13_Radar/DEM/DEM_ALOS.tif")
# Mostrar el mapa de aspecto
plot(DEM , main = "MAPA DE ELEVACIONES DEM")

# Calcular el aspect
ASPECT <- terrain(DEM, opt = "aspect")

# Mostrar el mapa de aspecto
plot(ASPECT, main = "Mapa de Aspecto")

# Calcular la pendiente
SLOPE <- terrain(DEM, opt = "slope")

# Mostrar el mapa de pendiente
plot(SLOPE, main = "Mapa de Pendiente")

TOPO <- stack(DEM, SLOPE, ASPECT)

TOPO <- resample(TOPO, alos2_Gamma_pw)
plot(TOPO)

names(TOPO) <-  c("DEM", "SLOPE", "ASPECT")

pinus <- rgdal::readOGR("D:/cap_Radar/inventario_biomasa_wgs84/pinos_filabres_wgs_84.shp")

# Cargar la librería sf
library(sf)

# Filtrar por especie "PH"
pinus_PH <- pinus[pinus$ESPECIE == "PH", ]
pinus_PP <- pinus[pinus$ESPECIE == "PT", ]

#stack final de los set ya preparados
rasters1 <- stack(alos2_Gamma_pw, S1_2015_Gamma_pw,LANDSAT, TOPO)

plot(rasters1)

#hacemos el extract con un buffer de 50 metros para minimizar los posibles errores de proyección de coordenadas 
rasters1_extract <- raster::extract(rasters1,parcelas, buffer=50, fun=mean)

#extraemos los puntos
MALLA_SAR_50<-cbind(parcelas,rasters1_extract)

write.csv(MALLA_SAR_50, "MALLA_SAR_50.csv")

plot(MALLA_SAR_50, max.plot = 50)

names(MALLA_SAR_50)

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

v.2 <- vifstep(var.df, th=7) # Calcula el VIF para todas las variables, excluye una con el VIF mas alto (mayor que el umbral), repite el procedimiento hasta que no quede ninguna variable con VIF mayor que th.
v.2

re1 <- exclude(rasters1,v.2)
re1

names(re1)

plot(re1)

# Dividir los datos en un conjunto de entrenamiento (80%) y un conjunto de prueba 20%) para PH
set.seed(123)
train_index <- createDataPartition(y =DS_PH$Ctt_MC., p = 0.8, list = FALSE)
train_PH <-DS_PH[train_index, ]
test_PH <-DS_PH[-train_index, ]

summary(train_PH)

summary(test_PH)

# Dividir los datos en un conjunto de entrenamiento (70%) y un conjunto de prueba (30%)
set.seed(123)
train_index <- createDataPartition(y =DS_PP$Ctt_MC., p = 0.8, list = FALSE)
train_PP <-DS_PP[train_index, ]
test_PP <-DS_PP[-train_index, ]

summary(train_PP)

summary(test_PP)

# Definición de parámetros de control para entrenamiento de modelo con caret
fitControl <- trainControl(
  method = "repeatedcv",  # Método de validación cruzada: validación cruzada repetida
  number = 10,            # Número de pliegues en la validación cruzada: 10
  repeats = 5,            # Número de repeticiones de la validación cruzada: 5
  returnResamp = "all",   # Devolver todas las métricas de evaluación para cada repetición
  returnData = TRUE,      # Devolver datos originales junto con predicciones del modelo
  savePredictions = TRUE  # Guardar las predicciones del modelo
)

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

Predict_model_PP_AGB <- predict(model_PP_AGB, newdata=test_PP)

Observed_ctt <- test_PP$Ctt_MC.

tmp_ctt <- data.frame(Predict_model_PP_AGB, Observed_ctt)

ev<- caret::postResample(test_PP$Ctt_MC., Predict_model_PP_AGB)
ev

m1_PN <- tmp_ctt %>% dplyr::select( Predict_model_PP_AGB, Observed_ctt) %>%
  pivot_longer(cols = -Observed_ctt) %>%
  ggplot(aes(x = Observed_ctt, y = value)) + geom_point()+
  stat_smooth(aes(), method="lm", formula=y ~ x) +theme_bw()+
  ylab("Model Pinud pinaster (Mg·ha−1)")+ xlab("observed (Mg·ha−1)")+
  ggtitle("MODEL RF PP VS OBSERVED",subtitle = "R2=0.49 - RSME= 21.43 - %RSME= 16.90%")+
  geom_abline(intercept=0, slope=1, lwd=1, linetype=2, color="red")

m1_PN 

MgC_PP<- predict(rasters1, model_PP_AGB)

plot(MgC_PP)

#cortamos al area de los poligonos correspondientes a PP
MgC_PP_mask <- mask(MgC_PP, pinus_PP)

#Guardamos los resultados
writeRaster(MgC_PP_mask,filename = paste ("D:/cap_13_Radar/RESULTADOS/","MgC_PP_2015"), bylayer=TRUE, format="GTiff", overwrite=TRUE, sep="")

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

Predict_model_PH_AGB <- predict(model_PH_AGB, newdata=test_PH)

Observed_ctt <- test_PH$Ctt_MC.

tmp_ctt <- data.frame(Predict_model_PH_AGB, Observed_ctt)

ev<- caret::postResample(test_PH$Ctt_MC. ,Predict_model_PH_AGB)
ev

m1_PH <- tmp_ctt %>% dplyr::select( Predict_model_PH_AGB, Observed_ctt) %>%
  pivot_longer(cols = -Observed_ctt) %>%
  ggplot(aes(x = Observed_ctt, y = value)) + geom_point()+
  stat_smooth(aes(), method="lm", formula=y ~ x) +theme_bw()+
  ylab("Model RF Wt (Mg·ha−1)")+ xlab("observed (Mg·ha−1)")+
  ggtitle("MODEL RF Wt VS OBSERVED",subtitle = "R2=0.49 - RSME= 21.43 - %RSME= 16.90%")+
  geom_abline(intercept=0, slope=1, lwd=1, linetype=2, color="red")
 
m1_PH 

MgC_PH<- predict(rasters1, model_PH_AGB)

plot(MgC_PH)

MgC_PH_mask <- mask(MgC_PH, pinus_PH)

#Guardamos resultados en el disco
writeRaster(MgC_PH_mask,filename = paste ("D:/cap_13_Radar/RESULTADOS/","MgC_PH_2015"), bylayer=TRUE, format="GTiff", overwrite=TRUE, sep="")
