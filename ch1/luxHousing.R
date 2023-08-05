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

