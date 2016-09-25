import React from 'react'
import Button from './button'
import SearchContainer from '../containers/search_container'
import OldProject from '../project'

const Project = React.createClass({
  componentDidMount() {
    var project_id = document.getElementById("project").getAttribute("data-id")
    this.props.setProjectId(project_id)
  },

  handleSearchAll(e) {
    console.log("Search")
  },

  handleCSVExport(e) {
    var hiddenInput = document.getElementById("export-results-ids")

    // TODO need to replace this with managed state
    var payload = OldProject.getListedCollections()
    hiddenInput.setAttribute("value", payload)
  },

  render() {
    return (
      <div>
        <div className="row">
          <div className="col-sm-6">
            <Button
              btn_class="btn btn-success btn-block"
              content="This is the Rerun all Searches button"
              action={this.handleSearchAll} />
          </div>
          <div className="col-sm-6">
            <Button
              type="submit"
              btn_class="btn btn-primary btn-block"
              content="This is the export CSV results"
              action={this.handleCSVExport} />
          </div>
        </div>
        <br />
        <SearchContainer />
      </div>
    )
  }
})

export default Project
