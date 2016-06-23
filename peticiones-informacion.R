# Script para publicar el registro de peticiones de información de los grupos auditores de los distritos al Ayuntamiento de Madrid 

# URL de la hoja de cálculo con los datos
url.data <- "https://docs.google.com/spreadsheets/d/1L_kLylhVReaL7GiL1Q0PJjx_b6yWOf2EPuk4bxiOIEU/pub?gid=1250269168&single=true&output=csv"
library(RCurl)
library(rmarkdown)
library(yaml)
# Librería para la realización de mapas con google maps.
#library(plotGoogleMaps)

# Carga de los datos
data <- read.csv(text = getURL(url.data, .encoding = "UTF-8"), encoding = "UTF-8", header = T, stringsAsFactors = F)
headers <- gsub(".", " ", names(data), fixed=T)


# Número de columnas a procesar (las dos últimas no se procesan al tener datos confidenciales)
n <- ncol(data)

#' Title
#' Función que crea una cadena en formato Rmardown con el contenido de una sección de la ficha.
#'
#' @param name Cadena con el encabezado de la sección.
#' @param field Cadena con el contenido de la sección.
#'
#' @return Cadena con una sección de la ficha en formato Rmarkdown.
#' @export
#'
#' @examples
render.field <- function(name, field){
  return(paste("## ", name, "\n", field, "\n\n", sep=""))
}

#' Title
#' Función que crea un fichero con el contenido de una ficha en formato Rmarkdown. 
#' El nombre del fichero en formato Rmarkdown se toma del segundo campo que se supone es el título de ficha.
#' @param x Vector con los encabezados de sección.
#' @param y Vector con los contenidos de las secciones.
#'
#' @return None
#' @export
#'
#' @examples
render.record <- function(x, y){
  file.name <- paste("peticion-", gsub(":", "-", gsub("/", "-", gsub(" ", "-", y[1]))), ".Rmd", sep="")
  file.create(file.name)
  yamlheader <- as.yaml(list(title=paste("Petición", as.character(y[1]))))
  write(paste("---\n", yamlheader,"---\n\n", sep=""), file=file.name, append=T)
  write(unlist(Map(render.field, x[2:n], y[2:n])), file=file.name, append=T)
  render_site(file.name)
}


#' Función que genera todas las fichas en formato Rmarkdown.
#'
#' @param data Data frame con los registros de las fichas.
#'
#' @return None
#' @export
#'
#' @examples
render.all.records <- function(data){
  # Generar el índice
  file.create("index.Rmd")
  yamlheader <- "---
title: Peticiones de información de los grupos auditores del Ayuntamiento de Madrid
output:
  html_document:
    toc: false
    toc_float: false
    includes:
      before_body: doc_prefix_index.html
---\n\n"
  write(yamlheader, file="index.Rmd", append=T)
  write(unlist(lapply(data[,1], function(x) paste("- [Petición ", x, "](peticion-", gsub(":", "-", gsub("/", "-", gsub(" ", "-", x))), ".html)\n", sep=""))), file="index.Rmd", append=T)
  # Generar las peticiones
  lapply(1:nrow(data), function(i) render.record(headers, data[i,]))
}

render.all.records(data)

render_site()
