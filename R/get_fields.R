#' Get all configured fields in a Jira instance
#'
#' Jira contains a large number of both system-supplied and user-configurable
#' fields. This function fetches the full list of available fields and
#' their metadata.
#'
#' @return dataframe
#' @export
#'
#' @importFrom dplyr bind_cols select
#' @importFrom purrr pluck
#' @importFrom rlang .data
#'
#' @examples
#' NULL
get_fields <- function() {
  all_fields <- jira_api("/rest/api/3/field")$content
  dplyr::bind_cols(dplyr::select(all_fields, -.data$schema),
                   purrr::pluck(all_fields, "schema"))
}
