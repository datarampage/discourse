#' discourse_users_list
#'
#' Get a list of all Discourse users
#' @param base_url The base URL of your Discourse instance
#' @export

discourse_users_list <- function(base_url) {

  require(httr)
  require(purrr)
  require(tidyverse)
  require(lubridate)

  #generate the URL to call

  url_chunk <- 'admin/users/list'
  flag <- 'active'
  filetype <- 'json'

  url <- paste(paste(base_url,url_chunk,flag,sep='/'),filetype,sep = '.')

  #get the API keys from the system environment

  api_key <- Sys.getenv('discourse_api_key')
  api_name <- Sys.getenv('discourse_api_name')

  #prep the API call

  headers <- add_headers(`Api-Key` = api_key, `Api-Username` = api_name)

  #since the API doesn't provide a total number of pages, we need to run through it until we run out of results
  #the API will return a 200 response as long as the URL is ok, but the results will be empty once you run out of users to get
  #this generates a data frame that is stacked and racked like Lego

  users_df <- tibble()
  increment <- 0

  repeat {

    query_params <- list(
      page = increment,
      order = "username",  # example of adding another query parameter
      asc = "true",         # example of adding another query parameter
      show_emails = "true"
    )

    response <- GET(url,query = query_params,headers)

    response2 <- content(response,'parsed')

    #check if you've run out of JSON objects to parse

    if (length(response2) == 0) {

      print('finished all calls')
      break

    } else {

      #convert all NULLs to NA
      test <- map(response2,nullToNA)
      #incrementally work through all objects
      test2 <- tibble()
      for (i in 1:length(test)) {

        #throw away nested fields we don't need

        test[[i]]$title <- NULL
        test[[i]]$manual_locked_trust_level <- NULL
        test[[i]]$secondary_emails <- NULL

        temp_df <- as_tibble(test[[i]]) %>%
          #fix the timestamp fields
          mutate(across(ends_with("_at"), ymd_hms))

        test2 <- bind_rows(test2,temp_df)

      }
      users_df <- bind_rows(users_df,test2)
      print(paste('page ',increment,' processed',sep=''))
      #update the pagination
      increment <- increment + 1

    }

  }

  return(users_df)

}
