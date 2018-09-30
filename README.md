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
<td>endpoint of the Jira API (ex. https//yourdomain.atlassian.net)</td>
</tr>
<tr class="even">
<td>JIRA_USER</td>
<td>username (ex. <a href="mailto:youraccount@example.com" class="email">youraccount@example.com</a>)</td>
</tr>
<tr class="odd">
<td>JIRA_API_KEY</td>
<td>API token as set via id.atlassian.net</td>
</tr>
</tbody>
</table>

Usage
-----

Full docs are coming…

``` r
library(dplyr)
library(sprintr)

# find the ID of the board of interst
get_boards()

# pull up details on a board
get_board_details(board_id = <x>)

# identify the sprint of interest
get_sprints(board_id = <x>) %>% arrange(desc(endDate))

# get a sprint report
sprint_report <- get_sprint_report(sprint_id = <x>)
# the report has quite a bit of info, for raw story point totals
sprint_report$points_sum

# pull up details on a specific issue
get_issue(issue_key = "XXX-1234")
# or see all the fields on that issue
get_issue("XXX-1234", full_response = TRUE)

# the main personal motivation of this package
sprint_report_detail <- get_sprint_report_detail(sprint_id = <x>)
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
