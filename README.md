# Locorum

Current version on GitHub: 0.4.2

Check local listings, assess accuracy, fix issues.

For development, visit [`localhost:4000`](http://localhost:4000) from your browser.

For deployed v0.4.2, visit [Locorum](https://boiling-beach-47326.herokuapp.com/) from your browser.

## v0.5 to do list
- Enhance persisted search results experience
  - Allow user to clear older results from search/edit menu
    - ADD: in router :locate, added -> get "/search/collections", ResultCollectionsController, :index
    - ADJ: in router, removed :index from resources ResultCollectionsController
    - ADJ: in router, rename "results/project/:id" to "project/results/:id"
    - ADJ: result_collection :index displays all available result collections for a particular search (controller and html)
    - ADJ: adjust results/index.html "manage results" link to result_collection_path :index
  - Limit dropdown for "Show Older Results" persisted data to 5 most recent ResultCollections, save last 10
- Fix broken Backends
  - WhitePages
- When a backend doesn't work, let the user know that it timed outap

## v0.6 to do list
- Delete isolated files
  - DEL: results.js
  - DEL: SearchChannel
  - DEL: search :index, :show
  - DEL: results :show
- Setup admin, manage:
  - Users
  - Backends
    - Allow admin to disable some backends
      - Implement show.html to Handle
      - Migrate add "up" boolean, default to true
  - All projects
- Allow user to ignore individual results so they won't show up in results again
- DRY refactor
  - phonify in SearchController
  - get_refer in numerous (i.e., ResultCollectionController)
- Add documentation
  - project.js especially
  - Modules (backends not necessary)
- Testing
  - Add unit testing for Project, Result, ResultCollection, User
  - Backends

## v0.7 to do list
- Add chat capabilities
  - By search/results
  - Link to #slack
- Error check CSV upload
- Errata
  - project.js, changing href for link to results does not update DOM

## v1.0 to do list
- Check redirects after deletes
  - Maybe AJAX to create objects? Prevents "cancel" from returning to new or edit page

## Long term to do list
- Replace geocode from Google to pull from a CSV with data
  - Use an Agent that loads when the app loads
  - How do we make it available to all of the backends? Assign it to the scoket? :geocode_pid?
- Add more backends. Priorities: Acxiom, Foursquare, Superpages
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
- Use "name" instead of "biz" for search
- Refactor backends to avoid n+1
  - Bing is a big violator
- Create better overview for each search

## Changelog

### v0.5
- Created additional tests:
  - project_controller_test
- Deprecated search functionality. Source files still maintained until v0.6
  - DEL: "results" button for each search on project :show
  - DEL: "view results" button for modal on project :show
  - DEL: "View this search in new tab" from results/project :index
  - DEL: get "/results/:id" from router :locate
  - ADJ: resources "/search" in router to only: [:update, :delete, :create, :new, :edit]
  - ADJ: search_controller :update redirect from search :show to project :show
  - ADJ: search_controller :create redirect from results_path :show to project :show
  - ADJ: removed portions of SearchControllerTest that reference search :index, :show
  - ADJ: removed search :show link from the results/project :index, but keep name
  - ADJ: SearchControllerTest "creates search and redirects to results page" redirected from results_path :show to project :show
  - ADJ: SearchControllerTest to fixed SearchControllerTest
- Enhanced persisted search results experience
  - Now allows user to clear older results from search/edit menu

### v0.4.2
- Socket authentication added
- Updated CityGrid key to production value
- Removed Searches from main menu

### v0.4.1
- Bug fixes
  - Fixed issue where export results button would display when no collections were loaded.
  - Fixed issue where no results would crash BackendSys
  - Fixed issue where Supervisor terminates if a backend is missing from the Repo. Backends are loaded from the Repo now.
  - Fixed issue where phone would return a higher rating even if incorrect. If the phone number does not match, it now receives a fixed lower rating (50)
  - Fixed multiple "Backend...loading" prints backends: menu on Search when supervisor restarts
  - project :index no longer displays "Results" option if no searches exist for a given project. Replaced with "Add Searches" button, which links to project :show where the user can add searches to the project.
- Rating system updated. Established fixed scores for numeric comparisons, since the jaro_distance method will still provide a relatively high rating for incorrect numbers, particularly within the same area code.
  - A non-matching zip code will return a rating of 20
  - A non-matching phone will return a rating of 50
- No longer using %Header{} in each backend. Helpers will pull backend data from repo based on module name.
- Added backends: Bing, Neustar Localeze, Facebook, Yelp, MapQuest
- Removed Collection Admin from main menu
- Breaking Changes
  - Had to reenter all backend module names (must include Elixir.BackendSys)
- Replaced pop_first with Enum.drop
- Added geocode to Helpers
  - Returns lat and lng map for a given zip code
- Added Facebook key to heroku deployment

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
