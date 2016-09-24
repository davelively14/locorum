var initialState = {
  search_id: undefined,
  older_results: [],
  search_info: {}
}

const search = (state = initialState, action) => {
  switch(action.type) {
    case 'SET_SEARCH_ID':
      return Object.assign({}, state, {
        search_id: action.id
      })

    case 'ADD_OLDER_RESULT':
      return Object.assign({}, state, {
        older_results: state.older_results.push(action.result)
      })

    default:
      return state
  }
}

export default search
