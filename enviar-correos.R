# Enviar peticiones de información por correo al Ayuntamiento

# URL de la hoja de cálculo con los datos de las fichas
url.data <- "https://docs.google.com/spreadsheets/d/1L_kLylhVReaL7GiL1Q0PJjx_b6yWOf2EPuk4bxiOIEU/pub?gid=1250269168&single=true&output=csv"

# Carga de los datos
require(RCurl)
data <- read.csv(text = getURL(url.data, .encoding = "UTF-8"), encoding = "UTF-8", header = T, stringsAsFactors = F)

# Función que obiene el nombre normalizado para una ficha. 
getName <- function (x) {
  name <- gsub(" ", "-", tolower(iconv(x, to='ASCII//TRANSLIT')))
  name <- gsub("/", "-", name)
  name <- gsub(":", "-", name)
  return(paste("peticion-", name, sep=""))
}

load("peticiones.enviadas.Rda")

enviar.peticion <- function (peticion){
  require(mailR)
  sender <- "madridauditamadrid@gmail.com"
  recipients <- c("auditoria@madrid.es")
  send.mail(from = sender,
            to = recipients,
            subject=paste("Nueva petición de información de la Auditoría Ciudadana", peticion),
            body = paste("Desde la Auditoría Ciudadana de la Deuda del Ayuntamiento de Madrid os remitimos una nueva petición de información que hemos recibido. Podéis acceder a los detalles de la petición a través del siguiente enlace:\n\n",
                         "http://pacd-madrid.github.io/peticiones-informacion/", getName(peticion), ".html\n\n", "Un saludo.", sep=""),
            smtp = list(host.name = "smtp.gmail.com", port = 465, user.name = "madridauditamadrid@gmail.com", passwd = "audita16", ssl = TRUE),
            authenticate = TRUE,
            send = TRUE)
  
}

for (peticion in data[["Marca.temporal"]]) {
  if (!any(grepl(peticion,peticiones.enviadas[["peticion"]]))){
    enviar.peticion(peticion)
    peticiones.enviadas <- rbind(peticiones.enviadas, setNames(as.list(c(peticion)), names(peticiones.enviadas)), stringsAsFactors=FALSE)
  }
}

save(peticiones.enviadas, file="peticiones.enviadas.Rda")


