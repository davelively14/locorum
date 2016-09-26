import {connect} from 'react-redux'
import Search from '../components/search'
import {setSearchId, addOlderResult, setSearchCritera} from '../actions/index'

const mapStateToProps = (state) => {
  return {
    state
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    setSearchId: (id) => {
      dispatch(setSearchId(id))
    },
    addOlderResult: (result) => {
      dispatch(addOlderResult(result))
    },
    setSearchCritera: (search_criteria) => {
      dispatch(setSearchCritera(search_criteria))
    }
  }
}

const SearchContainer = connect(mapStateToProps, mapDispatchToProps)(Search)

export default SearchContainer
