# Locorum

Current version: 0.2

Check local listings, assess accuracy, fix issues.

For development, visit [`localhost:4000`](http://localhost:4000) from your browser.

For deployed v0.1, visit [Locorum](https://boiling-beach-47326.herokuapp.com/) from your browser.

## v0.3 to do list
- Create links to user
  - Project
  - Search
- Create project_channel
- Integrate with search_channel
- Use CSV input and output

## v0.4 to do list
- Add more backends. Priorities: Bing, Facebook, Yelp, MapQuest, Foursquare, Superpages
- Fix WhitePages nil return

## Long term to do list

- Add some sort of loading notification for each backend to the frontend.
- Enhance side menu summary for backends
  - Use an icon to indicate overall accuracy for each backend (st: develop a rating system)
- Persist results of each search. Let the user revisit them without running the search. Compare progress.
- Handle a lot of results (i.e. more than 10)
  - Use limit option to determine. Let the user set the limit
- Clean up passed info/supervision trees
- Determine how to cleanup processes if needed. Can they self-kill?
- Add tests for:
  - Model: user (requires: user authentication)
  - Controller: results_controller
  - Channel: search_channel, backend_sys
- Find a new name

## Recently completed
- Deployed v0.2
- Create Project
  - General routes: new, update, index, show, delete
- Added user authentication
