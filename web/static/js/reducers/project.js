var initialState ={
  export_button_visible: false
}

const project = (state = initialState, action) => {
  switch(action.type) {
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
