# Lade die notwendigen Packages
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("readr")) install.packages("readr")
if (!require("utils")) install.packages("utils")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("sf")) install.packages("sf")
if (!require("rnaturalearth")) install.packages("rnaturalearth")
devtools::install_github("ropensci/rnaturalearthdata")

# Lade die Libraries
library(tidyverse)
library(readr)
library(utils)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

# Definiere die Funktion
load_statpop_data <- function(url, year) {
  # Lade die ZIP-Datei herunter und speichere sie temporär mit der wininet Methode
  temp <- tempfile(fileext = ".zip")
  download.file(url, temp, mode = "wb", method = "wininet")
  
  # Liste die Dateien im ZIP-Archiv auf
  files <- utils::unzip(temp, list = TRUE)
  
  # Finde die größte Datei im Archiv
  largest_file <- files$Name[which.max(files$Length)]
  
  # Überprüfe, ob die größte Datei eine CSV-Datei ist
  if (!grepl(".csv$", largest_file)) {
    stop("Die größte Datei im ZIP-Archiv ist keine CSV-Datei.")
  }
  
  # Entpacke die größte Datei
  utils::unzip(temp, files = largest_file, exdir = tempdir())
  
  # Lese die CSV-Datei ein und gebe das Semikolon als Trennzeichen an
  csv_path <- file.path(tempdir(), largest_file)
  data <- readr::read_delim(csv_path, delim = ";")
  
  return(data)
}

# Beispielaufruf der Funktion
url <- "https://dam-api.bfs.admin.ch/hub/api/dam/assets/27965868/master"
year <- 2022
data <- load_statpop_data(url, year)



# Lade die Schweizer Karte
world <- ne_countries(scale = "medium", returnclass = "sf")
switzerland <- world %>% filter(sovereignt == "Switzerland")

# Konvertiere die Koordinaten in ein sf-Objekt
data_sf <- data %>%
  st_as_sf(coords = c("E_KOORD", "N_KOORD"), crs = 2056) %>% # LV03 Koordinatensystem (EPSG:21781)
  st_transform(crs = 4326) # Umwandlung in WGS84 (EPSG:4326) für die Darstellung

# Zeichne die Karte
ggplot() +
  geom_sf(data = switzerland, fill = "white", color = "black") +
  geom_sf(data = data_sf, aes(size = B22BTOT), color = "blue", alpha = 0.5) +
  coord_sf(xlim = c(5.5, 10.5), ylim = c(45.5, 48), expand = FALSE) +
  theme_minimal() +
  labs(title = "Haushalte in der Schweiz",
       subtitle = "Visualisierung der Haushalte basierend auf den Koordinaten",
       x = "Längengrad",
       y = "Breitengrad",
       size = "Anzahl der Haushalte")
