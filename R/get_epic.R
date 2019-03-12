#' Get all available epics on a specific board
#'
#' Fetches all visible epics in a given Jira board, returning them and their
#' metadata as a dataframe.
#'
#' @return dataframe
#' @export
#'
#' @param board_id ID of the origin board to retrieve sprints
#'
#' @importFrom dplyr bind_rows select
#' @importFrom tibble tibble
#' @importFrom purrr pluck
#' @importFrom rlang .data
#' @importFrom glue glue
#'
#' @examples
#' NULL
get_epics <- function(board_id) {
  content <- list(isLast = FALSE,
                  startAt = 0,
                  maxResults = 0)

  all_epics <- tibble::tibble()

  while (!content$isLast) {
    start_at <- content$startAt + content$maxResults
    url <- glue::glue("/rest/agile/1.0/board/{board_id}/epic/?",
                      "startAt={start_at}")

    content <- jira_api(url) %>%
      purrr::pluck("content")

    epics <- purrr::pluck(content, "values") %>%
      dplyr::select(.data$id, .data$key, .data$self, .data$name, .data$summary, .data$done, color = .data$color$key)

    all_epics <- dplyr::bind_rows(all_epics, epics)
  }
  all_epics
}

#' Get details on a specific epic
#'
#' Using an epic_key, get the full details on an epic.
#'
#' @param epic_key Key of epic to retrieve
#'
#' @importFrom tibble tibble
#' @importFrom purrr pluck
#' @importFrom rlang na_lgl
#' @return A tibble.
#' @export
#'
#' @examples
#' \dontrun{
#' get_epic("XXX-1234")
#' }
get_epic <- function(epic_key) {
  resp <- jira_api(glue::glue("/rest/agile/1.0/epic/{epic_key}")) %>%
    purrr::pluck("content", "fields")
  tibble::tibble(
    key = epic_key,
    name = purrr::pluck(resp, "name", .default = NA_character_),
    summary = purrr::pluck(resp, "summary",
                           .default = NA_character_),
    done = purrr::pluck(resp, "done",
                           .default = rlang::na_lgl),
    color = purrr::pluck(resp, "color", "key", .default = NA_character_)
  )
}

#' Get all issues associated with a given epic
#'
#' With a given epic key, find all of the associated issues.
#'
#' @param epic_key Key of issue to retrieve
#' @param jql Atlassian JQL through which to filter results
#'
#' @importFrom tibble tibble
#' @importFrom dplyr bind_cols
#' @importFrom purrr pluck
#' @importFrom glue glue
#'
#' @return A tibble.
#' @export
#'
#' @examples
#' \dontrun{
#' get_issues_by_epic("XXX-1234")
#'
#' }
get_issues_by_epic <- function(epic_key, jql = NULL) {
  check_storypoint_mapping()
  resp <- jira_api(glue::glue("/rest/agile/1.0/epic/{epic_key}/issue"),
                   query = list("jql" = jql)) %>%
    purrr::pluck("content", "issues")
  if (is.null(resp)) {
    tibble::tibble()
  } else {
    issue_details <-
      tibble::tibble(
        story_points = purrr::pluck(resp, "fields", pkg.globals$story_points,
                                          .default = NA_integer_),
        epic_name = purrr::pluck(resp, "fields", "epic", "name", .default = NA_character_),
        program = purrr::pluck(resp, "fields", pkg.globals$program, "value",
                               .default = NA_character_),
        status = purrr::pluck(resp, "fields", "status", "name", .default = NA_character_)
      )
    dplyr::bind_cols(tibble::tibble(epic_key = epic_key, issue_key = resp$key), issue_details)
  }
}

