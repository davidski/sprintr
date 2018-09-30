jira_url <- function() {
  endpoint <- Sys.getenv('JIRA_API_URL', "")
  if (endpoint == "") stop("Jira API url not found.", .call = FALSE) else endpoint
}

jira_username <- function() {
  user <- Sys.getenv('JIRA_USER', "")
  if (user == "") stop("Jira API user not found.", .call = FALSE) else user
}

jira_token <- function() {
  token <- Sys.getenv('JIRA_API_KEY', "")
  if (token == "") stop("Jira API key not found.", .call = FALSE) else token
}

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
#' @importFrom httr modify_url GET http_type accept_json authenticate content
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' NULL
jira_api <- function(path, query = NULL) {
  url <- httr::modify_url(jira_url(), path = path, query = query)
  resp <- httr::GET(url, httr::accept_json(),
                    httr::authenticate(jira_username(), jira_token()))
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
#' @importFrom httr modify_url POST http_type accept_json authenticate content
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' NULL
jira_api_post <- function(path, post_data) {
  url <- httr::modify_url(jira_url(), path = path)
  resp <- httr::POST(url, httr::accept_json(),
                     httr::authenticate(jira_username(), jira_token()),
               body = post_data, encode = "json")
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
