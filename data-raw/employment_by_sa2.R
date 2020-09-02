## code to prepare `employment_by_sa2` dataset goes here
#Data from 2016 census - table builder

employment_industry_sa2 <- read_csv("data-raw/employment_by_industry_by_sa2.zip", 
                                    skip = 10, 
                                    col_names = c("counting", 
                                                  "sa2_name_2016",
                                                  "industry",
                                                  "value")) %>%
  filter(!is.na(industry),
         sa2_name_2016 != "Total",
         industry != "Total") %>%
  select(industry, sa2_name_2016, value) %>%
  group_by(sa2_name_2016) %>%
  mutate(industry_share = value/sum(value)) %>%
  ungroup() %>%
  group_by(industry) %>%
  mutate(industry_aus = sum(value)) %>%
  ungroup() %>%
  group_by(sa2_name_2016) %>%
  mutate(sa2_share = industry_aus/sum(industry_aus)) %>%
  ungroup() %>%
  group_by(industry, sa2_name_2016, employment = value) %>%
  summarise(rca_employment = industry_share/sa2_share, .groups = 'drop') %>%
  ungroup()



usethis::use_data(employment_industry_sa2, overwrite = TRUE)

map_data <- left_join(employment_industry_sa2, payroll_industry) %>% 
  group_by(sa2_name_2016) %>% 
  mutate(value = (value-100)/100) %>% 
  summarise(employment_impact = round(sum(rca_employment*value, na.rm = T)), 2) %>% 
  left_join(max_ind) %>%
  left_join(sa22016) %>%
  st_as_sf()

pal <- colorBin("Reds", map_data$employment_impact, 8, pretty = TRUE, reverse = TRUE)

leaflet(map_data) %>% 
  addTiles() %>%
  addPolygons(
    color = 'white',
    weight = 1,
    fillColor = ~pal(employment_impact),
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 2,
      color = 'blue',
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = ~str_c(sa2_name_2016, ": ", (employment_impact), " (",industry, ")")) %>%
  addLegend(
    position = "bottomright",
    pal = pal,
    values = map_data$employment_impact)
  
