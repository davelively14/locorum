var initialState = {
  project_id: undefined,
  export_button_visible: false,
  searches: []
}

const project = (state = initialState, action) => {
  switch(action.type) {
    case 'SET_PROJECT_ID':
      return Object.assign({}, state, {
        project_id: action.id
      })

    case 'SHOW_EXPORT_BUTTON':
      return Object.assign({}, state, {
        export_button_visible: true
      })

    case 'HIDE_EXPORT_BUTTON':
      return Object.assign({}, state, {
        export_button_visible: false
      })

    default:
      return state
  }
}

export default project
