## code to prepare `mobility_facebook` dataset goes here
update_mobility_facebook <- function() {
  
  rhdx::set_rhdx_config(hdx_site = "prod")
  
  
  
  download_facebook <- function() {
    
    rhdx::search_datasets("Movement Range Maps") %>%
      purrr::pluck(1) %>%
      rhdx::get_resource(2) %>%
      rhdx::download_resource(folder = "data-raw", filename = "facebook.zip", force = TRUE)
  }
  
  read_facebook <- function() {
    
    fname <- unzip("data-raw/facebook.zip", list = TRUE) %>%
      dplyr::filter(Length == max(.$Length)) %>%
      dplyr::pull(Name)
    
    readr::read_tsv(unz("data-raw/facebook.zip", fname)) 
  }
  
  download_facebook() 
  
  fb_mobility <-   read_facebook() %>%
    dplyr::filter(country == "AUS") %>%
    dplyr::select(state = polygon_name,
           date = ds,
           single_location = all_day_ratio_single_tile_users) %>%
    tidyr::pivot_longer(cols = single_location,
                 names_to = "metric",
                 values_to = "trend") %>%
    dplyr::mutate(date = lubridate::date(date),
           weekday = lubdirate::wday(date))
  
  
  lga_to_state <- strayr::read_absmap(name = "lga2016", remove_year_suffix = TRUE) %>%
    dplyr::mutate(lga_name = gsub(pattern = " \\(.+\\)",
                                x = lga_name,
                                replacement = "")) %>%
    dplyr::as_tibble() %>%
    dplyr::select(lga_name_2016, state_name_2016)
  
  mobility_facebook <- dplyr::bind_rows(aitidata:::mobility_facebook_2020,
                                 fb_mobility) %>%
    dplyr::left_join(lga_to_state, by = c("state" = "lga_name_2016"))
  
  file.remove("data-raw/facebook.zip")
  
  usethis::use_data(mobility_facebook, compress = "xz", overwrite = TRUE)
  return(TRUE)
}
