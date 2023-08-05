#writing my own script from the Bruno Rodrigues book "building reproducible analyticl pipelines in R"

library(dplyr)
library(purrr)
library(readxl)
library(stringr)
library(janitor)

#the url below oints to an excel file 
#hosted on the book's github repository
url <- "https://is.gd/1vvBAc"

raw_data <- tempfile(fileext = ".xlsx")

download.file(url, raw_data, method = "auto", mode = "wb")

sheets <- excel_sheets(raw_data)

#reads a specified sheet from an Excel file and then adds a new column to the data that contains the name or index of that sheet.
read_clean <- function(..., sheet){
  read_excel(..., sheet = sheet) |> 
    mutate(year = sheet)
}

raw_data <- map(
  sheets, 
  ~read_clean(raw_data, 
              skip = 10, 
              sheet = .)
                   ) |> 
  bind_rows() |> 
  clean_names()

raw_data <- raw_data |>
  rename(
    locality = commune, 
    n_offers = nombre_doffres, 
    average_price_nominal_euros = prix_moyen_annonce_en_courant,
    average_price_m2_nominal_euros = prix_moyen_annonce_au_m2_en_courant, 
    average_price_m2_nominal_euros = prix_moyen_annonce_au_m2_en_courant
  ) |> 
  mutate(locality = str_trim(locality)) |>
  select(year, locality, n_offers, starts_with("average"))

