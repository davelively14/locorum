import React from 'react'
import Button from './button'

const Project = React.createClass({
  handleSearchAll() {
    console.log("Search")
  },

  handleCSVExport() {
    console.log("CSV");
  },

  render() {
    return(
      <div>
        <h3>Project is wired up</h3>
        <div className="col-sm-6">
          <Button btn_class="btn btn-success btn-block" content="This is the Rerun all Searches button" action={this.handleSearchAll} />
        </div>
        <div className="col-sm-6">
          <Button btn_class="btn btn-primary btn-block" content="This is the export CSV results" action={this.handleCSVExport} />
        </div>
      </div>
    )
  }
})

export default Project
