import {combineReducers} from 'redux'
import project from './project'
import search from './search'

const projectApp = combineReducers({
  project,
  search
})

export default projectApp
