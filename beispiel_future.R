# Erstellen von Test Files zum Wiedereinlsen
# Es werden 5000 Files mit dem Datensatz iris geschrieben.
n_files <- 1:5000

write_file <- function(n_file){
  file_name <- paste0("data/file_", n_file, ".csv")

  write.csv(iris, file_name)
}


purrr::walk(n_files, write_file)

# ------------------------------------------------------------------------------

# Files zum Einlesen
# Die Files werden enmal seriell und einmal parallel eingelesen
# Um den Prozess etwas grösser zu machen, macht die Einlesefunktion noch einen
# pivot_longer


# Einlesefunktion mit pivot_longer
read_iris_file <- function(file_path){

  data <- read.csv(file_path)

  data_iris_long <- tidyr::pivot_longer(data, cols = dplyr::matches("\\."), names_to = "var")

  return(data_iris_long)
}

# Fuktion zum einlesen mehrerer Files mit Progressbar
# Wir hier für die Parallelisierung benötigt um einen geschlossenen Prozess
# zu erstellen
read_multiple_files <- function(list_file_names, p){
  p()
  purrr::map_df(list_file_names, read_iris_file)
}


# Alle Filepaths, welche eingelesen werden sollen
files_to_read <- list.files("data", full.names = TRUE)


# Unterteilen der Filepaths in 7 Chunks
# Jeder chunk kann dann auf einem anderen Worker prozessiert werden
list_for_furrr <- split(
  files_to_read,
  seq_along(files_to_read) %% 7
)

# Hier können wir abfragen, wie viele Workers insgesamt zur verfügung stehen
future::availableCores()

# Hier setzten wir fest, dass wir sieben workers verwenden möchten um die
# sieben Chunks zu prozessieren.
future::plan("multisession", workers = 7)


# Hier lassen wir den Code seriell ausführen und messen die Zeit
system.time(test1 <- purrr::map_df(files_to_read, read_iris_file, .progress = TRUE))

# Hier lassen den Code parallel prozessieren und messen die Zeit
system.time(progressr::with_progress({
  p <- progressr::progressor(steps = length(list_for_furrr))
  test <- furrr::future_map_dfr(list_for_furrr, ~read_multiple_files(., p = p))
  })
)
