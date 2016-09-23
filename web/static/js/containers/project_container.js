import {connect} from 'react-redux'
import Project from '../components/project'
import {hideExportButton, showExportButton} from '../actions/index'

const mapStateToProps = (state) => {
  return {
    export_button_visible: state.export_button_visible,
    active_results: state.active_results
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    showExportButton: () => {
      dispatch(showExportButton())
    },
    hideExportButton: () => {
      dispatch(hideExportButton())
    },
    updatedActiveResults: (results) => {
      dispatch(updatedActiveResults(results))
    }
  }
}

const ProjectContainer = connect(mapStateToProps, mapDispatchToProps)(Project)

export default ProjectContainer
