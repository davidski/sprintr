#' Get details on a specific issue
#'
#' Using an issue_key, get the full details on an issue. Defaults to returning a
#' minimal set of fields as a dataframe, but may also be used to retrieve any
#' or all available fields.
#'
#' @param issue_key Key of issue to retrieve
#' @param fields Comma separated string of field IDs to retrieve
#' @param full_response Return raw list of fields
#'
#' @return A tibble if neither `fields` nor `full_response` are specified, otherwise a list
#' @export
#'
#' @examples
#' \dontrun{
#' # basic details on an issue as tibble
#' get_issue("XXX-1234")
#'
#' # a custom field set as list
#' get_issue("XXX-1234", fields = 'status,resolution')
#'
#' # all available fields as list
#' get_issue("XXX-1234", full_response = TRUE)
#' }
get_issue <- function(issue_key, fields = NULL, full_response = FALSE) {
  resp <- jira_api(glue::glue("/rest/agile/1.0/issue/{issue_key}"),
                   query = list(fields = fields)) %>%
    purrr::pluck("content", "fields")
  if (is.null(fields) && !full_response) {
    tibble::tibble(
      key = issue_key,
      story_points = purrr::pluck(resp, pkg.globals$story_points,
                                  .default = NA_integer_),
      epic_name = purrr::pluck(resp, "epic", "name", .default = NA_character_),
      program = purrr::pluck(resp, pkg.globals$program, "value",
                             .default = NA_character_),
      status = purrr::pluck(resp, "status", "name", .default = NA_character_)
    )
  } else {
    resp
  }
}

#' Parse an issue.
#'
#' EXPERIMENTAL: Parse an issue response into a dataframe.
#'
#' @param response HTTR response
#'
#' @return dataframe
#' @export
#'
#' @importFrom tibble tibble
#'
#' @examples
#' NULL
parse_issue <- function(response) {
  tibble::tibble(
    key = "DUMMY",
    story_points = purrr::pluck(response, pkg.globals$story_points,
                                .default = NA_integer_),
    epic_name = purrr::pluck(response, "epic", "name",
                             .default = NA_character_),
    program = purrr::pluck(response, pkg.globals$program, "value",
                           .default = NA_character_)
  )
}
