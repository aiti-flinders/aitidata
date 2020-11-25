update_abs_lookup_table <- function() {
  
  # scrape the main page
  abs_stats_page <- xml2::read_html("https://www.abs.gov.au/statistics",
                                    user_agent = readabs_user_agent)
  
  main_page_data <- dplyr::tibble(
    heading = abs_stats_page %>% rvest::html_nodes(".field--type-ds h3") %>% rvest::html_text() %>% stringi::stri_trim_both(),
    url_suffix = abs_stats_page %>% rvest::html_nodes(".card") %>% rvest::html_attr("href") %>% stringi::stri_trim_both()
  )
  
  # scrape each page
  
  scrape_sub_page <- function(sub_page_url_suffix) {
    main_page_heading <- main_page_data$heading[main_page_data$url_suffix == sub_page_url_suffix]
    
    
    sub_page <- xml2::read_html(glue::glue("https://www.abs.gov.au{sub_page_url_suffix}"))
    
    sub_page_data <- dplyr::tibble(
      heading = main_page_heading,
      sub_heading = sub_page %>% rvest::html_nodes(".abs-layout-title") %>% rvest::html_text() %>% stringi::stri_trim_both(),
      catalogue = sub_page %>% rvest::html_nodes("#content .card") %>% rvest::html_attr("href") %>%
        stringi::stri_replace_all_fixed(sub_page_url_suffix, "") %>%
        stringi::stri_replace_all_regex("/[^/]*$", "") %>%
        stringi::stri_replace_all_fixed("/", ""),
      url = glue::glue("https://www.abs.gov.au{sub_page_url_suffix}/{catalogue}/latest-release"),
    )
  }

  
  return(new_abs_lookup_table)
}