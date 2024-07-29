### rio 

install.packages("rio")


### before rio

write.csv(iris, "iris.csv")
saveRDS(iris, "iris.rds")
save(iris, "iris.Rdata")
# 2013: No way to write to spss

x <- read.csv("iris.csv")
x <- readRDS("iris.rds")
x <- read.spss("iris.sav")
load("iris.Rdata")


### with rio

rio::import("https://www.web.statistik.zh.ch/ogd/daten/ressourcen/KTZH_00002643_00005443.csv") %>% 
  tibble::tibble()

rio::import("https://www.web.statistik.zh.ch/ogd/daten/ressourcen/KTZH_00002622_00005363.xlsx") %>% 
  tibble::tibble()

rio::import("https://www.web.statistik.zh.ch/ogd/daten/ressourcen/KTZH_00002462_00005003.zip") %>% 
  tibble::tibble()


rio::import("https://www.web.statistik.zh.ch/ogd/daten/ressourcen/KTZH_00002462_00005003.zip", which = "10_Schulhaus Albisriederplatz.csv") %>% 
  tibble::tibble()


rio::import("https://www.web.statistik.zh.ch/ogd/daten/ressourcen/KTZH_00002462_00005003.zip", which = "106_Schlüechti.csv")
