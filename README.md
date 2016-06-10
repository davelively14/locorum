# Locorum

Current version on GitHub: 0.4.1a

Check local listings, assess accuracy, fix issues.

For development, visit [`localhost:4000`](http://localhost:4000) from your browser.

For deployed v0.4.0, visit [Locorum](https://boiling-beach-47326.herokuapp.com/) from your browser.

## v0.4.1 to do list

## v0.5 to do list
- Add more backends. Priorities: Bing, Facebook, Yelp, MapQuest, Foursquare, Superpages
- Implement ResultCollection management
  - Cleanup at a minimum, delete collections
- Fix WhitePages nil return
- Add chat capabilities
  - By search/results
  - Link to #slack
- Enhance persisted search results experience
  - Allow user to clear older results from search/edit menu
  - Limit persisted data to 3 most recent ResultCollections
- Allow user to ignore individual results so they won't show up in results again
- User authentication for socket
- Refactor
  - Create better overview for each search
  - Use "name" instead of "biz" for search
  - results.js to search.js
- Testing
  - Add unit testing for Project, Result, ResultCollection, User
  - Backends
- Error check CSV upload
- Allow admin to disable backends from admin menu
  - Implement show.html to Handle
  - Migrate add "up" boolean, default to true
- Errata
  - Fix multiple "Backend...loading" prints backends: menu on Search when supervisor restarts
  - How do we persist "no results"?
    - Are empty backends saved in resultsContainer?
    - Do we propagate all backends regardless? YES
- Check TODOs

## v0.6 to do list
- Setup admin
  - Can manage other users
  - Can manage all projects
- Add helper for pop_first
  - csv_controller calls Locorum.BackendSys.Helpers.pop_first right now
- DRY refactor
  - phonify in SearchController
  - get_refer in numerous (i.e., ResultCollectionController)
- Limit number of ResultCollection per Search

## v1.0 to do list
- Deprecate
  - search :index
  - search :show

## Long term to do list

- Create an agent to manage results
  - First time a search is called, agent will load most recent. Every time search is run, the agent will store the most recent collection and save it to the repo.
  - Should it load on restart?
    - Probably not. Wouldn't scale well and it's true usefulness is as a cache for often requested results.
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

### v0.4.1
- Bug fixes
  - Fixed issue where export results button would display when no collections were loaded.
- No longer use %Header{} in each backend. Helpers will pull backend data from repo based on module name.
- Breaking Changes
  - Must reenter all backend module names (must include Elixir.BackendSys)

### v0.4
- Export results to CSV
- Testing
  - Fixed unit testing for SearchControllerTest
- Enhanced persisted search results experience
  - Now allow user to select older results, sort by date
  - Display "as of" for each search

### v0.3.2
- Bug fixes
  - Fixed "view results in new tab" bad link for persisted results
  - Fixed search :edit bad call to deprecated search.name
- Reworded buttons and links for project screen
- Updated project/show interface. Click on search to view information in modal.
  - Added search/show to deprecate list

### v0.3.1
- Improved home Page
- Better links

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
- Created overview for each search in Project
- Run search for individual searches within a Project
- Persisted search results
  - Load on project load
  - Load on search load
  - Created results table
  - Created backend table
  - Created result_collection table
  - Delete associated results when result_collection is deleted
