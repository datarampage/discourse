#' discourse_auth
#'
#' Authenticate your Discourse API account
#' @param api_key The API key
#' @param api_name The Discourse account name
#' @export

discourse_auth <- function(account_id,api_name) {

  Sys.setenv('discourse_api_key' = api_key)
  Sys.setenv('discourse_api_name' = api_name)

}
