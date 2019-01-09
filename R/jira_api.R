jira_url <- function(endpoint = NULL) {
  if (!is.null(endpoint)) Sys.setenv(JIRA_API_URL = endpoint)
  endpoint <- Sys.getenv('JIRA_API_URL', "")
  if (endpoint == "") stop("Jira API url not found.", call. = FALSE) else endpoint
}

jira_username <- function(username = NULL) {
  if (!is.null(username)) Sys.setenv(JIRA_USER = username)
  user <- Sys.getenv('JIRA_USER', "")
  if (user == "") stop("Jira API user not found.", call. = FALSE) else user
}

jira_token <- function(api_key = NULL) {
  if (!is.null(api_key)) Sys.setenv(JIRA_API_KEY = api_key)
  token <- Sys.getenv('JIRA_API_KEY', "")
  if (token == "") stop("Jira API key not found.", call. = FALSE) else token
}

jira_oauth_ssl_key <- function(key_file = NULL) {
  if (!is.null(key_file)) Sys.setenv(JIRA_OAUTH_SSL_KEY = key_file)
  key_file <- Sys.getenv('JIRA_OAUTH_SSL_KEY', "")
  if (key_file == "") stop("Jira OAUTH SSL key not found.", call. = FALSE) else key_file
}

jira_authtype <- function() {
  token_auth <- oauth_auth <- NA_character_
  oauth_auth <- tryCatch(jira_oauth_ssl_key(), error = function(e) NA_character_)
  token_auth <- tryCatch(jira_token(), error = function(e) NA_character_)
  if (is.na(oauth_auth) & is.na(token_auth)) stop("Could not find Jira authenticaiton credentials.", call. = FALSE)
  if (!is.na(oauth_auth)) {return("oauth")} else {return("token")}
}

#' @importFrom openssl read_key
jira_oauth_token <- function() {
  jira_endpoints <- httr::oauth_endpoint(
    "request-token", "authorize", "access-token",
    base_url = httr::modify_url(jira_url(), path = "plugins/servlet/oauth"))
  jira_app <- httr::oauth_app("sprintr", key = jira_username(), secret = jira_token())
  jira_token <- httr::oauth1.0_token(jira_endpoints, jira_app,
                                     private_key = openssl::read_key(jira_oauth_ssl_key()))
  jira_token
}

# default variables
# thanks to http://www.exegetic.biz/blog/2017/09/global-variables-r-packages/
pkg.globals <- new.env()
pkg.globals$story_points <- "customfield_10013"
pkg.globals$program      <- "customfield_10500"

#' Execute a GET request against the Jira API
#'
#' Calls bare API end points and returns a wrapped `httr` response object
#' to a higher level function for presentation.
#'
#' @param path API endpoint to retrieve
#' @param query Named list of parameters to use as the URL query
#'
#' @return A jira_api object
#' @export
#'
#' @importFrom httr modify_url GET http_type accept_json authenticate content config
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' NULL
jira_api <- function(path, query = NULL) {
  url <- httr::modify_url(jira_url(), path = path, query = query)
  params <- list(httr::accept_json())
  if (jira_authtype() == "oauth") {
    params <- c(params, httr::config(token = jira_oauth_token()))
  } else {
    params <- c(params, httr::authenticate(jira_username(), jira_token()))
  }
  resp <- httr::GET(url, params)
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(httr::content(resp, "text"), simplifyVector = TRUE)

  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "jira_api"
  )
}

#' Execute a POST request against the Jira API
#'
#' Calls bare API end points and returns a wrapped `httr` response object
#' to a higher level function for presentation.
#'
#' @param path API endpoint to retrieve
#' @param post_data List of data to post to API
#'
#' @return A jira_api object
#' @export
#'
#' @importFrom httr modify_url POST http_type accept_json authenticate content config
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' NULL
jira_api_post <- function(path, post_data) {
  url <- httr::modify_url(jira_url(), path = path)
  params <- list(httr::accept_json())
  if (jira_authtype() == "oauth") {
    params <- c(params, httr::config(token = jira_oauth_token()))
  } else {
    params <- c(params, httr::authenticate(jira_username(), jira_token()))
  }
  resp <- httr::POST(url, params, body = post_data, encode = "json")
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  parsed <- jsonlite::fromJSON(httr::content(resp, "text"), simplifyVector = TRUE)

  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "jira_api"
  )
}

print.jira_api <- function(x, ...) {
  cat("<JIRA ", x$path, ">\n", sep = "")
  utils::str(x$content)
  invisible(x)
}
