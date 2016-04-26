# Locorum

Current version: 0.2b

Check local listings, assess accuracy, fix issues.

For development, visit [`localhost:4000`](http://localhost:4000) from your browser.

For deployed v0.1, visit [Locorum](https://boiling-beach-47326.herokuapp.com/) from your browser.

## Immediate to do list
- Populate phone for each result
- Populate url_result for each result
- Change results
  - url_result for backends: CityGrid, Google, Local, WhitePages, Yahoo
  - Phone number for backends: yp.com, CityGrid, Google, Local, WhitePages, Yahoo
- Add CSV input (and/or excel?)

## Long term to do list

- Find way around White Pages issue. Change up headers?
- Add more backends. Priorities: Bing, Facebook, Yelp, MapQuest, Foursquare, Superpages
- Add some sort of loading notification for each backend to the frontend.
- Enhance side menu summary for backends
  - Use an icon to indicate overall accuracy for each backend (st: develop a rating system)
- Persist results of each search. Let the user revisit them without running the search. Compare progress.
- Handle a lot of results (i.e. more than 10)
  - Use limit option to determine. Let the user set the limit
- Clean up passed info/supervision trees
- Add user authentication
- Determine how to cleanup processes if needed. Can they self-kill?
- Add tests for:
  - Model: user (requires: user authentication)
  - Controller: results_controller
  - Channel: search_channel, backend_sys
- Find a new name

## Recently completed
- Deployed v0.1
- Change Search
  - Added :phone
- Changed Results struct
  - Added change link
  - Added phone number
- Change search/:show
  - Added phone number, with phonify
- Change results
  - url_result for backends: yp.com
  - Phone number for backends:
