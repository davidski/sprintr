#' Get sprint report data
#'
#' The Jira sprint report is a useful snapshot of issues completed, not completed,
#' and changes to sprint scope. While the web UI does not provide a way to
#' export this data in a workable format, the API can be used to get at the
#' raw data.
#'
#' @param board_id ID of board
#' @param sprint_id ID of sprint to retrieve
#'
#' @return dataframe
#' @export
#'
#' @importFrom glue glue
#' @importFrom purrr discard pluck keep flatten_df map splice
#' @importFrom stringr str_detect
#'
#' @examples
#' NULL
get_sprint_report <- function(board_id, sprint_id) {
  sprint_report <- jira_api(
    glue::glue("/rest/greenhopper/1.0/rapid/charts/sprintreport?",
               "rapidViewId={board_id}&sprintId={sprint_id}")) %>%
    purrr::pluck("content", "contents")
  discard_list <- names(sprint_report) %>%
    stringr::str_detect(pattern = "Sum")
  clean_report <- purrr::discard(sprint_report, discard_list)
  point_sums <- purrr::keep(sprint_report, discard_list) %>%
    purrr::map("value") %>% purrr::flatten_df()
  purrr::splice(clean_report, list(points_sum = point_sums))
}

#' Get detailed sprint report information.
#'
#' Get the issues associated with each of the major categories in a
#' Jira sprint report. Currently retrieves all fields of all issues, which
#' can be slow.
#'
#' @param board_id ID of board
#' @param sprint_id ID of the sprint to pull issue-level details on
#'
#' @return A dataframe
#' @export
#' @importFrom dplyr mutate bind_rows
#' @importFrom purrr map_dfr
#'
#' @examples
#' NULL
get_sprint_report_detail <- function(board_id, sprint_id) {
  sprint_report <- get_sprint_report(board_id = board_id, sprint_id = sprint_id)
  sprint_report$completedIssues$key %>%
    purrr::map_dfr(function(x) get_issue(issue_key = x)) %>%
    dplyr::mutate(type = "completed") -> comp_issues
  sprint_report$issuesNotCompletedInCurrentSprint$key %>%
    purrr::map_dfr(function(x) get_issue(issue_key = x)) %>%
    dplyr::mutate(type = "incomplete") -> incomp_issues
  sprint_report$puntedIssues$key %>%
    purrr::map_dfr(function(x) get_issue(issue_key = x)) %>%
    dplyr::mutate(type = "removed") -> removed_issues
  sprint_report$issueKeysAddedDuringSprint %>% names() %>%
    purrr::map_dfr(function(x) get_issue(issue_key = x)) %>%
    dplyr::mutate(type = "added") -> added_issues
  sprint_report_detail <- dplyr::bind_rows(comp_issues, incomp_issues,
                                           removed_issues, added_issues) %>%
    dplyr::mutate(sprint_id = sprint_id)
  sprint_report_detail
}

#' Get all backlogged issues.
#'
#' Retrieves all the issues that are on a board's backlog.
#'
#' @param board_id ID of board to retrieve
#'
#' @return dataframe
#' @export
#'
#' @examples
#' NULL
get_issues_on_backlog <- function(board_id) {
  start_at <- 0
  resp <- jira_api(glue::glue("/rest/agile/1.0/board/{board_id}/backlog",
                              "?startAt={start_at}"))
  resp_values <- resp %>% purrr::pluck("content", "issues", "fields")
  while (resp$content$startAt + resp$content$maxResults < resp$content$total) {
    start_at <- start_at + 50
    resp <- jira_api(glue::glue("/rest/agile/1.0/board/{board_id}/backlog?",
                                "startAt={start_at}&maxResults=50"))
    resp_values <- dplyr::bind_rows(resp_values,
                                    purrr::pluck(resp, "content", "issues", "fields"))
  }

  resp_values
}
