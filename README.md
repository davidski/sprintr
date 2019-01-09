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

| variable       | purpose                                                                                           |
|----------------|---------------------------------------------------------------------------------------------------|
| JIRA\_API\_KEY | API token obtained via [id.atlassian.net](https://id.atlassian.net)                               |
| JIRA\_USER     | username (ex. <a href="mailto:youraccount@example.com" class="email">youraccount@example.com</a>) |

### Jira Server Authentication

My available versions of Jira Server do not support the same API as Jira
Cloud. While **sprintr** aims for the lowest common denominator, there
may be unexpected differences when operating on a Jira Server endpoint.
Bug reports and PRs are very welcome!

To authenticate to Jira Server, you can use either use basic
authentication or OAuth1.0 authentication. Basic authentication, while
simpler, is **not recommended** and is provided only for local testing.
Basic authentication will send your credentials unencrypted (apart from
any HTTPS in use) across the network.

#### Basic Authentication

| variable    | purpose                                                                                           |
|-------------|---------------------------------------------------------------------------------------------------|
| JIRA\_USER  | username (ex. <a href="mailto:youraccount@example.com" class="email">youraccount@example.com</a>) |
| JIRA\_TOKEN | password                                                                                          |

#### OAuth1.0 Authentication

Jira’s server edition uses signed Oauth 1.0 authentication. You, or your
Jira server administrator, will need to create an Oauth endpoint. This
endpoint should specify a return url of `http://localhost:1410`. As part
of the setup process, your administrator will generate an OAuth consumer
secret (short text string), a shared secret (short text string), and a
private key (a long PEM-formatted key). The private key should be stored
in a secure location on your installation of sprintr. Configure the
following environment variables:

| variable              | purpose                                |
|-----------------------|----------------------------------------|
| JIRA\_USER            | OAuth Consumer Secret                  |
| JIRA\_API\_KEY        | Oauth Shared Secret                    |
| JIRA\_OAUTH\_SSL\_KEY | full path to a PEM encoded private key |

Usage
-----

Full docs are coming…

``` r
library(tidyverse)
library(sprintr)

# find the Story Point field identifier for your environment
find_story_point_mapping()

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
