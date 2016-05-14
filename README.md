# Locorum

Current version: 0.2b

Check local listings, assess accuracy, fix issues.

For development, visit [`localhost:4000`](http://localhost:4000) from your browser.

For deployed v0.2, visit [Locorum](https://boiling-beach-47326.herokuapp.com/) from your browser.

## v0.3 to do list
- Persist search results
  - Create results table
  - Associate with searches
  - Load on project/search load
  - Display "as of" for each search
- Create overview for each search
  - Project
  - Search

## v0.4 to do list
- User authentication for socket
- Refactor to use "name" instead of "biz" for search

## v0.5 to do list
- Add more backends. Priorities: Bing, Facebook, Yelp, MapQuest, Foursquare, Superpages
- Fix WhitePages nil return

## Long term to do list

- Add some sort of loading notification for each backend to the frontend.
- Enhance side menu summary for backends
  - Use an icon to indicate overall accuracy for each backend (st: develop a rating system)
- Handle a lot of results (i.e. more than 10)
  - Use limit option to determine. Let the user set the limit
- Add tests for:
  - Model: user (requires: user authentication), results
  - Controller: results_controller
  - Channel: search_channel, backend_sys, project_channel
- Update tests for:
  - Model: search (needs user to be logged in)
- Find a new name

## Changelog

### v0.3
- Created Project
  - General routes: new, update, index, show, delete, edit, update
- Added user authentication
- Created links to user
  - Project
  - Search
- Can add searches to projects individually
- Add searches to projects by CSV
- Deprecate name of search from forms
- Restart backends automatically when they fail
- Created project_channel
- Shows loading status for each search
  - Displays "loaded" when complete
- Removed "name" from search
