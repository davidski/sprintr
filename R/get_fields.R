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
  all_fields <- jira_api("/rest/api/2/field")$content
  dplyr::bind_cols(dplyr::select(all_fields, -.data$schema),
                   purrr::pluck(all_fields, "schema"))
}

#' Update the internal mapping of the field containing story points
#'
#' The story point field in Jira unfortunately is mapped to a random
#' custom field identifier in each instance/project. `find_story_point_mapping()`
#' queries the field list and updates the `sprintr` mapping. This value is
#' not persisted and needs to be re-run each session.
#'
#' @return Invisibly returns the new value of the story points field
#' @export
#'
#' @importFrom glue glue
#'
#' @examples
#' NULL
find_story_point_mapping <- function() {
  fields <- get_fields()
  sp_field <- fields[fields$name == "Story Points", "id"]
  message(glue::glue("Mapping story_points to {sp_field}."))
  pkg.globals$story_points <- sp_field
  return(invisible(sp_field))
}
