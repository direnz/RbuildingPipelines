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

# The overall code reads, cleans, transforms, and selects specific columns from an Excel file's sheets and stores the result in raw_data.
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


#fixing mispellings for the communes
raw_data <- raw_data |> 
  mutate(
    locality = fielse(grep(grep1("Luxembourg-Ville", locality),
                           "Luxembourg", locality),
                      locality = ifelse(grep1("P.tange",locality), "Pétange", locality)) |>
      mutate(across(starts_with("average"),as.numeric))
  )

#removing rows stating sources
raw_data <- raw_data |> filter(!grepl("Source", locality))

#only keep the communes in our data
commune_level_data <- raw_data |> filter(!grepl("nationale|offres", locality),!is.na(locality))

#creating a dataset with national data
country_level <- raw_data |> filter(grepl("Total d.offres", locality)) |> select(-n_offers)

offers_country <- raw_data |> filter(grepl("Total d.offres", locality)) |> select(year, n_offers)

country_level_data <- full_join(country_level, offers_country) |> select(year, locality, n_offers, everything()) |>
  mutate(locality = "Grand-Duchy of Luxembourg")

#Joining with 'by = join_by(year)


#scraping wikipedia for a list of communes to use for comparison pg 54
current_communes <- "https://w.wiki/6nPu" |>
  rvest::read_htlm() |>
  rvest::html_table() |>
  purr::pluck(1)  |>
  janitor::clean_names()

#compare communes
setdiff(unique(commune_level_data$locality), current_communes$commune)

#using list from wiki of communes from 2010 and beyond then we will harmonize spelling
former_communes <- "https://w.wiki/_wFe7" |>
  rvest::read_html() |>
  rvest::html_table() |>
  purrr::pluck(3) |>
  janitor::clean_names() |>
  dplyr::filter(year_dissolved > 2009)


#former_communes

#we will now combine the list of former and current communes and harmonize their names
communes <- unique(c(former_communes$name, current_communes$commune))

#we need to rename some communes

#different spelling of these communes between wiki and the data

communes[which(communes == "Clemency")] <- "Clémency"

communes[which(communes == "Redange")] <- "Redange-sur-Attert"

communes[which(communes == "Erpeldange-sur-Sûre")] <- "Erpeldange"

communes[which(communes == "Luxembourg-City")] <- "Luxembourg"

communes[which(communes == "Käerjeng")] <- "Kaerjeng"

communes[which(communes == "Petange")] <- "Pétange"

#running test again
setdiff(unique(commune_level_data$locality), communes)
















