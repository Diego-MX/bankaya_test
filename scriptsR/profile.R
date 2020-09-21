# Especificar el repositorio para descargar paquetes... Yay ITAM. 
cran_repo <- getOption("repos")
cran_repo["CRAN"] <- "https://cran.itam.mx/"
options(repos=cran_repo)
rm(cran_repo)

# Frases motivadoras
if (interactive()) try(fortunes::fortune(), silent=TRUE)

readRenviron("../.env")

# Para explorar tablas rápidamente. 
classes <- function (df) { tibble(
    name  = names(df), 
    class = sapply(df, . %>% {class(.)[1]})
)}





