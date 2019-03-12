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
  sp_field <- find_field(fields, name = "Story Points", type = "number")
  message(glue::glue("Mapping story_points to {sp_field}."))
  pkg.globals$story_points <- sp_field
  options("sprintr_storypoint_remapped" = TRUE)
  return(invisible(sp_field))
}

#' Update the internal mapping of the field containing capability
#'
#' This is a custom field likely only used by the package author. Until
#' a more flexible method is devised, this helper function finds the
#' value of the capability field in the Jira schema.
#'
#' @return Invisibly returns the new value of the capability field
#' @export
#'
#' @importFrom glue glue
#'
#' @examples
#' NULL
find_capability_mapping <- function() {
  fields <- get_fields()
  cap_field <- find_field(fields, name = "Capability", type = "option")
  message(glue::glue("Mapping program to {cap_field}."))
  pkg.globals$program <- cap_field
  return(invisible(cap_field))
}

#' Find the ID of a field in the Jira schema, given the field name and type
#'
#' Specifying both the name and the type of the field is necessary to
#' avoid issues with fields that have the same name, but multiple types
#' defined.
#'
#' @return The ID of the field in the schema
#' @param fields Output of `get_fields()`
#' @param name Name of the field to find
#' @param type Type of the field to find
#'
#' @examples
#' NULL
find_field <- function(fields, name, type) {
  fields[fields$name == name & fields$type == type, "id"]
}
