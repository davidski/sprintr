#' Get detailed information on a particular sprint
#'
#' Given a particular sprint ID, retrieve the descriptive information about
#' that sprint.
#'
#' @param sprint_id ID of the sprint to retrieve
#'
#' @return A tibble
#' @export
#'
#' @importFrom glue glue
#' @importFrom purrr pluck
#' @importFrom tibble tibble
#'
#' @examples
#' NULL
get_sprint <- function(sprint_id) {
  jira_api(glue::glue("/rest/agile/1.0/sprint/{sprint_id}")) %>%
    purrr::pluck("content") %>% as.tibble()
}

#' Get sprints associated with a board
#'
#' Return all of the sprints associated with a specific board. As a project
#' may have multiple boards, in order to retrieve all sprints in a given
#' project the user must query all boards and combine the results.
#'
#' @param board_id ID of the origin board to retrieve sprints
#'
#' @return dataframe
#' @export
#'
#' @importFrom dplyr bind_rows
#' @importFrom glue glue
#' @importFrom purrr pluck
#'
#' @examples
#' NULL
get_all_sprints <- function(board_id) {
  start_at <- 0
  resp <- jira_api(glue::glue("/rest/agile/1.0/board/{board_id}/sprint?",
                              "startAt={start_at}&maxResults=50"))
  resp_values <- resp %>% purrr::pluck("content", "values")
  #browser()
  while (!is.null(resp$content$isLast) && resp$content$isLast == FALSE) {
    start_at <- start_at + 50
    resp <- jira_api(glue::glue("/rest/agile/1.0/board/{board_id}/sprint?",
                                "startAt={start_at}&maxResults=50"))
    resp_values <- dplyr::bind_rows(resp_values,
                                    purrr::pluck(resp, "content", "values"))

  }
  resp_values
}