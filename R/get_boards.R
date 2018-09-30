#' Get all available boards
#'
#' Fetches all visible boards in the Jira instance and returns them, and their
#' metadata, as a dataframe.
#'
#' @return dataframe
#' @export
#'
#' @importFrom dplyr bind_cols bind_rows select
#' @importFrom tibble tibble
#' @importFrom purrr pluck
#' @importFrom rlang .data
#' @importFrom glue glue
#'
#' @examples
#' NULL
get_boards <- function() {
  content <- list(isLast = FALSE,
                  startAt = 0,
                  maxResults = 0)

  all_boards <- tibble::tibble()

  while (!content$isLast) {
    start_at <- content$startAt + content$maxResults
    url <- glue::glue("/rest/agile/1.0/board/?",
                      "startAt={start_at}")

    content <- jira_api(url) %>%
      purrr::pluck("content")

    values <- purrr::pluck(content, "values")

    boards <- dplyr::bind_cols(dplyr::select(values, -.data$location),
                               purrr::pluck(values, "location"))

    all_boards <- dplyr::bind_rows(all_boards, boards)
  }
  all_boards
}

#' Get details on a specific board
#'
#' Fetches detailed information on a specific board.
#'
#' @param board_id ID of sprint board to retrieve
#'
#' @return dataframe
#' @export
#'
#' @importFrom glue glue
#' @importFrom purrr pluck
#' @importFrom tibble as.tibble
#'
#' @examples
#' NULL
get_board_details <- function(board_id) {
  jira_api(glue::glue("/rest/agile/1.0/sprint/{board_id}")) %>%
    purrr::pluck("content") %>% tibble::as.tibble()
}
