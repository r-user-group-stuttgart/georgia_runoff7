
source("utils.R")
# ?get_targeting
# get_targeting("41459763029", timeframe = "LAST_90_DAYS")
# debugonce(get_targeting)

library(httr)
library(tidyverse)

tstamp <- Sys.time()

# source("utils.R")

last90days <- read_csv("data/FacebookAdLibraryReport_2022-11-25_US_last_90_days_advertisers.csv") %>%
  janitor::clean_names() %>%
  arrange(desc(amount_spent_usd)) %>%
  mutate(spend_upper = amount_spent_usd %>% as.numeric()) %>%
    arrange(-spend_upper) %>%
    mutate_all(as.character)


georgia_wtm <- readr::read_csv("data/wtm-advertisers-us-2022-11-28T14_22_01.338Z.csv") %>%
  select(page_name = name,
         page_id = advertisers_platforms.advertiser_platform_ref) %>%
  mutate(page_id = as.character(page_id))

# options(scipen = 999999)

# georgia_wtm

internal_page_ids <- georgia_wtm %>%
    mutate_all(as.character) %>%
      bind_rows(last90days)  %>%
      distinct(page_id, .keep_all = T)

# get_targeting(internal_page_ids$page_id[1], timeframe = "LAST_30_DAYS")

### save seperately
internal_page_ids %>% #count(cntry, sort  =T) %>%
  # filter(!(page_id %in% already_there)) %>%
  # filter(cntry == "GB") %>%
  # slice(1:10) %>%
  split(1:nrow(.)) %>%
  walk(~{
    try({


      print(paste0(.x$page_name,": ", round(which(internal_page_ids$page_id == .x$page_id)/nrow(internal_page_ids)*100, 2)))

      yo <- get_targeting(.x$page_id, timeframe = "LAST_7_DAYS") %>%
        mutate(tstamp = tstamp)

      if(nrow(yo)!=0){
        path <- paste0("midterms/",.x$page_id, ".rds")
        # if(file.exists(path)){
        #   ol <- read_rds(path)
        #
        #   saveRDS(yo %>% bind_rows(ol), file = path)
         # } else {

          saveRDS(yo, file = path)
        # }
      }

      print(nrow(yo))
    })


  })
