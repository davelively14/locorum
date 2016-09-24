import {connect} from 'react-redux'
import Search from '../components/search'
import {setSearchId, addOlderResult} from '../actions/index'

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
    }
  }
}

const SearchContainer = connect(mapStateToProps, mapDispatchToProps)(Search)

export default SearchContainer
