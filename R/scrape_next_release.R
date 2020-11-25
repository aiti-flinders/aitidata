scrape_next_release <- function(url) {
  next_release <- xml2::read_html(url) %>% rvest::html_nodes(xpath = '//*[@id="release-date-section"]/div[2]/div/div/ul/li[1]/span/text()') %>% rvest::html_text() 
  if (length(next_release) == 0) {
    next_release <- "01-01-1900"
  } else { next_release <- next_release %>% 
    stringi::stri_replace_all_fixed("Next Release ", "")
  }
  
  return(next_release)
}