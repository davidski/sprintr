% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/jira_api.R
\name{jira_api}
\alias{jira_api}
\title{Execute a GET request against the Jira API}
\usage{
jira_api(path, query = NULL)
}
\arguments{
\item{path}{API endpoint to retrieve}

\item{query}{Named list of parameters to use as the URL query}
}
\value{
A jira_api object
}
\description{
Calls bare API end points and returns a wrapped \code{httr} response object
to a higher level function for presentation.
}
\examples{
NULL
}
