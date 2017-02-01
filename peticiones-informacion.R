# Script para publicar el registro de peticiones de información de los grupos auditores de los distritos al Ayuntamiento de Madrid 
library(RCurl)
library(rmarkdown)
library(yaml)
library(airtabler)
library(dplyr)

# Carga de los datos desde Google Drive
# url.data <- "https://docs.google.com/spreadsheets/d/1L_kLylhVReaL7GiL1Q0PJjx_b6yWOf2EPuk4bxiOIEU/pub?gid=1250269168&single=true&output=csv"
# data <- read.csv(text = getURL(url.data, .encoding = "UTF-8"), encoding = "UTF-8", header = T, stringsAsFactors = F)

# Carga de datos desde AIRTABLE
Sys.setenv(AIRTABLE_API_KEY="keyZOgDPeLEn3Me8q")
datos <- airtable(base = "appe7uLXI2oMZ033Y", tables = c("Peticiones", "Respuestas", "Distritos", "Fichas ilegitimidad"))
peticiones <- datos$Peticiones$select()
respuestas <- datos$Respuestas$select()
distritos <- datos$Distritos$select()
fichas <- datos$`Fichas ilegitimidad`$select()
# PREPOCESAMIENTO DE DATOS
peticiones$id <- NULL
respuestas$id <- NULL
peticiones$createdTime <- NULL
respuestas$createdTime <- NULL
distritos$createdTime <- NULL
peticiones$Distrito <- unlist(peticiones$Distrito)
peticiones$Caso <- unlist(peticiones$Caso)
names(fichas)[names(fichas) == 'Título'] <- "Ficha"
# Fusionar tabla de peticiones con tabla de distritos
datos <- left_join(peticiones, distritos[c("id","Nombre")], by=c("Distrito"="id"))
datos$Distrito <- NULL
names(datos)[names(datos) == 'Nombre'] <- 'Distrito'
# Fusionar tabla de peticiones con tabla de fichas de ilegitimidad
datos <- left_join(datos, fichas[c("id","Ficha")], by=c("Caso"="id"))
datos$Caso <- NULL
names(datos)[names(datos) == 'Ficha'] <- 'Caso'
# Fusionar tabla de peticiones con tabla de respuestas
datos <- left_join(datos, respuestas, by="Registro")
# Calcular tiempo de respuesta
datos[["Tiempo respuesta"]] <- as.numeric(as.Date(datos[["Fecha respuesta"]])-as.Date(datos[["Fecha envío"]]))

# Reordenar las columnas y eliminar el correo y el colectivo 
#data <- data[c(1:4,11,5:8,12,13)]

# Obtener normbres de variables para las cabeceras de sección
#headers <- gsub(".", " ", names(data), fixed=T)

# Escala de satisfación
#data$Valoración.de.la.respuesta <- ifelse(is.na(data$Valoración.de.la.respuesta), 0, data$Valoración.de.la.respuesta) 
#satisfaccion <- c("Pendiente de valorar", "Nada satifactoria", "Poco satifactoria", "Moderadamente satisfactoria", "Bastante satisfactoria", "Completamente satisfactoria")
#data$Valoración.de.la.respuesta <- satisfaccion[data$Valoración.de.la.respuesta+1]

# Completar la fecha de respuesta cuando aún no hay respuesta
#data$Fecha.respuesta <- ifelse(data$Fecha.respuesta=="", "Aún sin respuesta", data$Fecha.respuesta) 

# GENERACIÓN DE FICHAS
for (i in 1:nrow(datos)){
  peticion = datos[i,]
  render('ficha_peticion.Rmd',
         output_format = "md_document", 
         output_file =  paste("peticion-", gsub("/","-",peticion$Registro) , ".Rmd", sep=''),
         output_dir = '.',
         quiet = TRUE)
}

render_site()
# clean_site()

