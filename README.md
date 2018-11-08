<!-- README.md is generated from README.Rmd. Please edit that file -->

Sprintr
=======

**sprintr** is a minimal R wrapper of the Jira and Jira Software REST
APIs. Convienience functions with object parsing are available for
retrieving sprint and velocity information. Bring the power of \#rstats
to your sprint reporting!

Installation
------------

`devtools::install_github("davidski/sprintr")`

Set the base url to your Jira API endpoint via the JIRA\_API\_URL
environment variable (typically via `.Renviron`).

<table>
<colgroup>
<col style="width: 52%" />
<col style="width: 47%" />
</colgroup>
<thead>
<tr class="header">
<th>variable</th>
<th>purpose</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>JIRA_API_URL</td>
<td>endpoint of the Jira API (ex. <a href="https://yourdomain.atlassian.net" class="uri">https://yourdomain.atlassian.net</a>)</td>
</tr>
</tbody>
</table>

### Atlassian Cloud Authentication

For Atlassian cloud installations, obtain a token via
[id.atlassian.net](https://id.atlassian.net) and set the `JIRA_API_KEY`
and `JIRA_USER` environment variables.

| variable              | purpose                                                                                           |
|-----------------------|---------------------------------------------------------------------------------------------------|
| JIRA\_API\_KEY        | API token obtained via [id.atlassian.net](https://id.atlassian.net)                               |
| JIRA\_USER            | username (ex. <a href="mailto:youraccount@example.com" class="email">youraccount@example.com</a>) |
| JIRA\_SESSION\_COOKIE | Session authentication cookie                                                                     |

### Jira Server Authentication

While much of the Jira Server API is the same as the cloud endpoints,
I’ve enountered many differences in practice and have not attempted to
support them here in **sprintr**. If you wish to explore on your own
(`jira_api()` and `jira_api_post()` both support making raw calls to the
API) then proceed with the following kludgey process to authenticate.

The **insecure** and **temporary** steps for authenticating to Jira
Server are:

1.  Visit the `/rest/auth/1/session` endpoint and authenticate with
    basic auth.
    (e.g. `curl -v --user YOURUID https://jira.yourdomain.tld/rest/auth1/session`)
2.  Copy out the JSESSIONID cookie value.
3.  Set an environment variable `JIRA_SESSION_COOKIE` to the value of
    the JSESSION cookie, taking care to omit the `=` and the `;` that
    mark the respective start and stop of the cookie value.

Session cookies will be preferred over API tokens, if available. Again,
this is a very kludgey work around for Jira Servers which do not support
OAuth.

| variable              | purpose                       |
|-----------------------|-------------------------------|
| JIRA\_SESSION\_COOKIE | Session authentication cookie |

Usage
-----

Full docs are coming…

``` r
library(tidyverse)
library(sprintr)

# find the ID of the board of interest
get_boards() %>% head(1) %>% pull(id) -> my_board

# pull up details on a board
get_board_details(board_id = my_board)

# identify the sprint of interest
get_all_sprints(board_id = my_board) %>% arrange(desc(endDate)) %>% 
  head(1) %>% pull(id) -> my_sprint

# get a sprint report
sprint_report <- get_sprint_report(sprint_id = my_sprint)
# the report has quite a bit of info, for raw story point totals
sprint_report$points_sum

# pull up details on a specific issue
get_issue(issue_key = "XXX-1234")
# or see all the fields on that issue
get_issue("XXX-1234", full_response = TRUE)

# the main personal motivation of this package
sprint_report_detail <- get_sprint_report_detail(board_id = my_board, sprint_id = my_sprint)
# do ggplot stuff!
```

References
----------

See the Atlassian [Jira
Cloud](https://developer.atlassian.com/cloud/jira/platform/rest) and
[Jira Software
Cloud](https://docs.atlassian.com/jira-software/REST/cloud)
docuementation for more information.

Contributing
------------

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.

License
-------

The [MIT License](LICENSE) applies.
