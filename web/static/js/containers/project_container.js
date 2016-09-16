import {connect} from 'react-redux'
import Project from '../components/project'
import {hideExportButton, showExportButton} from '../actions/index'

const mapStateToProps = (state) => {
  return {
    export_button_visible: state.export_button_visible
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    showExportButton: () => {
      dispatch(showExportButton())
    },
    hideExportButton: () => {
      dispatch(hideExportButton())
    }
  }
}

const ProjectContainer = connect(mapStateToProps, mapDispatchToProps)(Project)

export default ProjectContainer
