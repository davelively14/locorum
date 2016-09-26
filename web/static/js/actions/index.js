// For project.js
export const showExportButton = () => {
  return {
    type: 'SHOW_EXPORT_BUTTON'
  }
}

export const hideExportButton = () => {
  return {
    type: 'HIDE_EXPORT_BUTTON'
  }
}

export const setProjectId = (id) => {
  return {
    type: 'SET_PROJECT_ID',
    id
  }
}

export const setSearches = (searches) => {
  return {
    type: 'SET_SEARCHES',
    searches
  }
}

// For search.js
export const setSearchId = (id) => {
  return {
    type: 'SET_SEARCH_ID',
    id
  }
}

export const addOlderResult = (result) => {
  return {
    type: 'ADD_OLDER_RESULT',
    result
  }
}

export const setSearchCritera = (search_criteria) => {
  return {
    type: 'SET_SEARCH_CRITERIA',
    search_criteria
  }
}
