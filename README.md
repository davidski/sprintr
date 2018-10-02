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

The following environment variables must be set (typically via
`.Renviron`)

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
<tr class="even">
<td>JIRA_USER</td>
<td>username (ex. <a href="mailto:youraccount@example.com" class="email">youraccount@example.com</a>)</td>
</tr>
<tr class="odd">
<td>JIRA_API_KEY</td>
<td>API token obtained via <a href="https://id.atlassian.net">id.atlassian.net</a></td>
</tr>
</tbody>
</table>

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
sprint_report_detail <- get_sprint_report_detail(board_ud = my_board, sprint_id = my_sprint)
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
