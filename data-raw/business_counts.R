## code to prepare `business_counts` dataset goes here
library(readabs)
library(tibble)
library(purrr)
library(readxl)
library(stringr)
library(tibble)

abs_file <- download_abs_data_cube("counts-australian-businesses-including-entries-and-exits",
                                   cube = "8165DC08",
                                   path = "data-raw")
cabee_sheets <- excel_sheets(abs_file)
cabee_sheets <- str_extract(cabee_sheets, "\\d")
cabee_sheets <- cabee_sheets[!is.na(cabee_sheets)]
cabee_sheets <- cabee_sheets[str_detect(cabee_sheets, "b", negate = TRUE)]
cabee_sheets <- paste("Table", cabee_sheets)

# SA2 Business Counts include both point in time (odd # sheets) and annualised employment size ranges (even # sheets)
cabee_sheets <- cabee_sheets[grepl("[246]", cabee_sheets)]

cabee_sa2 <- tribble(
  ~"date",
  ~"industry_code",
  ~"industry_label",
  ~"sa2_main_2016",
  ~"sa2_name_2016",
  ~"non_employing",
  ~"employing_1_4",
  ~"employing_5_19",
  ~"employing_20_199",
  ~"employing_200_plus",
  ~"total"
)

cabee_years <- map(.x = cabee_sheets,
                   .f = function(x) read_excel(abs_file,
                                               sheet = x,
                                               col_names = "year",
                                               range = "A4") |> 
                     mutate(year = as.Date(paste0("01", str_extract_all(year, "June \\d+")), "%d %B %Y")) |> 
                     pull(year)) |> 
  list_c()

cabee_sa2 <- map2(.x = cabee_sheets,
                  .y = cabee_years,
                  .f = function(x,y) read_excel(abs_file,
                                                sheet = x,
                                                skip = 7,
                                                col_names = c(
                                                  "industry_code",
                                                  "industry_label",
                                                  "sa2_main_2016",
                                                  "sa2_name_2016",
                                                  "non_employing",
                                                  "employing_1_4",
                                                  "employing_5_19",
                                                  "employing_20_199",
                                                  "employing_200_plus",
                                                  "total"
                                                )) |> 
                    filter(!is.na(sa2_main_2016)) |> 
                    mutate(sa2_main_2016 = as.character(sa2_main_2016),
                           date = y)) |> 
  list_rbind()


cabee_sa2 <- cabee_sa2 |> 
  pivot_longer(cols = -c("industry_code", "industry_label", "sa2_main_2016", "sa2_name_2016", "date"),
                      names_to = "indicator",
                      values_to = "value") |> 
  select("date",
                division = "industry_label",
                "sa2_main_2016",
                "sa2_name_2016",
                "indicator", 
                "value")
file.remove(abs_file)

use_data(cabee_sa2, compress = "xz", overwrite = TRUE)


