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

jira_cookie <- function(session_cookie = NULL) {
  if (!is.null(session_cookie)) Sys.setenv(JIRA_SESSION_COOKIE = session_cookie)
  token <- Sys.getenv('JIRA_SESSION_COOKIE', "")
  if (token == "") stop("Jira session cookie not found.", call. = FALSE) else token
}

jira_authtype <- function() {
  token_auth <- cookie_auth <- NA_character_
  cookie_auth <- tryCatch(jira_cookie(), error = function(e) NA_character_)
  token_auth <- tryCatch(jira_token(), error = function(e) NA_character_)
  if (is.na(cookie_auth) & is.na(token_auth)) stop("Could not find cookie or token based credentials.", call. = FALSE)
  if (!is.na(cookie_auth)) {return("cookie")} else {return("token")}
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
#' @importFrom httr modify_url GET http_type accept_json authenticate content set_cookies
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' NULL
jira_api <- function(path, query = NULL) {
  url <- httr::modify_url(jira_url(), path = path, query = query)
  params <- list(httr::accept_json())
  if (jira_authtype() == "cookie") {
    params <- c(params, httr::set_cookies(JSESSIONID = jira_cookie()))
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
#' @importFrom httr modify_url POST http_type accept_json authenticate content set_cookies
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' NULL
jira_api_post <- function(path, post_data) {
  url <- httr::modify_url(jira_url(), path = path)
  params <- list(httr::accept_json())
  if (jira_authtype() == "cookie") {
    params <- c(params, httr::set_cookies(JSESSIONID = jira_cookie()))
  } else {
    params <- c(params, httr::authenticate(jira_username(), jira_token()))
  }
  resp <- httr::POST(url, httr::accept_json(), params(), body = post_data,
                     encode = "json")
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
