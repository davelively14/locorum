import {connect} from 'react-redux'
import Search from '../components/search'
import {changeSearchId, addOlderResult} from '../actions/index'

const mapStateToProps = (state) => {
  return {
    state
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    changeSearchId: () => {
      dispatch(changeSearchId())
    },
    addOlderResult: () => {
      dispatch(addOlderResult())
    }
  }
}

const SearchContainer = connect(mapStateToProps, mapDispatchToProps)(Search)

export default SearchContainer
