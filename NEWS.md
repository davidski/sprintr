# sprintr 0.1.0.9000

* Use package globals to configure commonly used custom fields
* `find_story_point_mapping()` detects the customfield id for story point fields
* Use the V2 API whenever possible over the V3 calls. V3 of the Jira API is not 
  available for on prem deployments and is still beta even for cloud environments.
* Bug fix - `jira_api_post()` calls were broken. :(


# sprintr 0.1.0

* Internal functions for working with `sprintr` environment variables can now 
  set as well set get their values. This is intended for development purposes.
* Bare bones support for Jira Server API calls via the JSESSION_ID hack.

# sprintr 0.0.0.9000

* `get_sprint_report_detail()` takes a board_id and a sprint_id parameter.
* `get_sprints()` renamed to `get_all_sprints()`.
* `get_sprint()` introduced to fetch details of a particular sprint.
* `get_boards()` now properly follows pagination (@quartin).
* `JIRA_API_KEY` properly documented (@quartin).
* `epic_name` correctly parsed from issues.
* Basic documentation added to functions.
* Added a `NEWS.md` file to track changes to the package.
