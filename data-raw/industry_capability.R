# ## code to prepare `industry_capability` dataset goes here
# library(tidyverse)
# library(aitidata)
# library(reticulate)
# 
# sa2_zero_businesses <- cabee_sa2 %>%
#   group_by(sa2_name_2016) %>%
#   summarise(total = sum(total)) %>%
#   ungroup() %>%
#   filter(total == 0) %>%
#   pull(sa2_name_2016)
# 
# 
# input_data <- cabee_sa2 %>%
#   select(industry = division, sa2_name_2016, date, total) %>%
#   filter(industry != "Currently Unknown") %>% 
#   mutate(date = lubridate::year(date)) %>%
#   replace_na(replace = list(total = 0))
# 
# ecomplexity <- import("ecomplexity")
# cols_input <- dict(time = "date", loc = "sa2_name_2016", prod = "industry", val = "total")
# out <- ecomplexity$ecomplexity(input_data, cols_input) %>%
#   as_tibble() %>%
#   filter(!is.nan(pci))
# 
# usethis::use_data(industry_capability, overwrite = TRUE)
