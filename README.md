# Locorum

Current version: unversioned

Check local listings and assess accuracy.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## To do list

- Find way around White Pages issue. Change up headers?
- Add more backends. Priorities: Bing, Facebook, yp.com, Citysearch, Yelp, MapQuest, Foursquare, Superpages
- Add some sort of loading notification for each backend to the frontend.
- Enhance side menu summary for backends
  - Use an icon to indicate overall accuracy for each backend (st: develop a rating system)
- Persist results of each search. Let the user revisit them without running the search. Compare progress.
- Handle a lot of results (i.e. more than 10)
  - Use limit option to determine. Let the user set the limit
- Clean up passed info/supervision trees
- Add user authentication
- Determine how to cleanup processes if needed. Can they self-kill?

## Recently completed
- Add ranking system to results
- Add backends: Google
- Enhance side menu summary for backends
  - Don't hyperlink until backend is loaded
  - Link to respective backends using #backend

## Deployment notes to myself

Need to check this before deploying: [deployment guides](http://www.phoenixframework.org/docs/deployment).
