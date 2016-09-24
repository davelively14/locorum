import {connect} from 'react-redux'
import Project from '../components/project'
import {hideExportButton, showExportButton, updatedActiveResults, setProjectId} from '../actions/index'

const mapStateToProps = (state) => {
  return {
    state
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
    },
    setProjectId: (id) => {
      dispatch(setProjectId(id))
    }
  }
}

const ProjectContainer = connect(mapStateToProps, mapDispatchToProps)(Project)

export default ProjectContainer
