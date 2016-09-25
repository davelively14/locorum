import {connect} from 'react-redux'
import Project from '../components/project'
import {hideExportButton, showExportButton, setSearches, setProjectId} from '../actions/index'

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
    setProjectId: (id) => {
      dispatch(setProjectId(id))
    },
    setSearches: (searches) => {
      dispatch(setSearches(searches))
    }
  }
}

const ProjectContainer = connect(mapStateToProps, mapDispatchToProps)(Project)

export default ProjectContainer
