## code to prepare `labour_force` dataset goes here. It contains data from 4 relevant releases of the 6202.0 series released on the 3rd Thursday of each month.
## Table 12. Labour force status by Sex, State and Territory - Trend, Seasonally adjusted and Original
## Table 19. Monthly hours worked in all jobs by Employed full-time, part-time and Sex and by State and Territory - Trend and Seasonally adjusted
## Table 22. Underutilised persons by Age and Sex - Trend, Seasonally adjusted and Original
## Table 23. Underutilised persons by State and Territory and Sex - Trend, Seasonally adjusted and Original

library(readabs)
library(dplyr)
library(tidyr)
library(lubridate)



#save(labour_force, file = here::here("data", "labour_force_australia.rda"), compress = "xz")
