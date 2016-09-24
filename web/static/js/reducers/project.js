var initialState = {
  project_id: undefined,
  export_button_visible: false,
  active_results: [],
  searches: []
}

const project = (state = initialState, action) => {
  switch(action.type) {
    case 'SET_PROJECT_ID':
      return Object.assign({}, state, {
        project_id: action.project_id
      })

    case 'SHOW_EXPORT_BUTTON':
      return Object.assign({}, state, {
        export_button_visible: true
      })

    case 'HIDE_EXPORT_BUTTON':
      return Object.assign({}, state, {
        export_button_visible: false
      })

    case 'UPDATE_ACTIVE_RESULTS':
      return Object.assign({}, state, {
        active_results: action.results
      })

    default:
      return state
  }
}

export default project
