var initialState = {
  // TODO pull data from db
  search_id: undefined,
  older_results: [],
  // TODO pull data from db
  search_info: []
}

const search = (state = initialState, action) => {
  switch(action.type) {
    case 'CHANGE_SEARCH_ID':
      return Object.assign({}, state, {
        search_id: action.id
      })

    case 'ADD_OLDER_RESULT':
      return Object.assign({}, state, {
        older_results: state.older_results.push(action.older_result)
      })

    default:
      return state
  }
}

export default search
