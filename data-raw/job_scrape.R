## code to prepare `job_scrape` dataset goes here
library(rvest)
library(tidyverse)
library(glue)

num_jobs <- read_html("https://www.seek.com.au/jobs?daterange=1&page=1&sortmode=ListedDate") %>%
  html_nodes(xpath = '//*[@id="SearchSummary"]/span/h1/strong') %>%
  html_text() %>%
  str_replace_all(",", "") %>%
  as.numeric()

num_pages <- ceiling(num_jobs / 22)

urls <- tibble(url = glue("https://www.seek.com.au/jobs?daterange=1&page={1:num_pages}&sortmode=ListedDate"))

get_job_ids <- function(url) {
  url <- read_html(url)
  job_ids <- tibble(job_ids = html_nodes(url, "article") %>% html_attr("data-job-id"))
}

scrape_job_page <- function(job_page_url_suffix) {
  sub_page <- try(read_html(glue("https://www.seek.com.au/job/{job_page_url_suffix}")))

  job_title <- possibly(~ html_nodes(sub_page, "article section span span h1") %>% html_text(), NA, quiet = FALSE)
  company <- possibly(~ html_nodes(sub_page, "article h2 span span") %>%
    .[1] %>%
    html_text(), NA)
  location <- possibly(~ html_nodes(sub_page, "div.Pdwn1mb section dl dd span.E6m4BZb span strong.lwHBT6d") %>%
    first() %>%
    html_text(), NA)
  sublocation <- possibly(~ html_nodes(sub_page, "div.Pdwn1mb section dl dd span.E6m4BZb span span.eBOHjGN") %>%
    first() %>%
    html_text(), NA)
  classification <- possibly(~ html_nodes(sub_page, "div.Pdwn1mb section dl dd span.E6m4BZb span strong.lwHBT6d") %>%
    last() %>%
    html_text(), NA)
  subclassification <- possibly(~ html_nodes(sub_page, "div.Pdwn1mb section dl dd span.E6m4BZb span span.eBOHjGN") %>%
    last() %>%
    html_text(), NA)

  # fields <- html_nodes(sub_page, "div.Pdwn1mb section dl dt") %>% html_text()
  sub_page_data <- tibble::tibble(
    seek_id = job_page_url_suffix,
    job_title = job_title(),
    company = company(),
    location = location(),
    sublocation = sublocation(),
    classification = classification(),
    subclassification = subclassification()
  )
}

job_ids <- map_dfr(urls$url, get_job_ids)

scraped_page <- map_dfr(job_ids$job_ids, scrape_job_page)

seek_data <- scraped_page %>%
  mutate(across(c(sublocation, subclassification), ~str_sub(., start = 3)),
         sublocation = ifelse(sublocation == subclassification, NA, sublocation),
         job_title = trimws(job_title),
         date_scraped = Sys.time())

seek_data <- bind_rows(seek_data, aitidata::seek_data)

usethis::use_data(seek_data, overwrite = TRUE, compress = 'xz')
