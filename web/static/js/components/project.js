import React from 'react'
import Button from './button'
import OldProject from '../project'

const Project = React.createClass({
  handleSearchAll(e) {
    console.log("Search")
  },

  handleCSVExport(e) {
    console.log("in export");
    console.log(e);
    var hiddenInput = document.getElementById("export-results-ids")
    console.log(hiddenInput);
    var payload = OldProject.getListedCollections()
    console.log(payload);
    hiddenInput.setAttribute("value", payload)
  },

  render() {
    return(
      <div>
        <h3>Project is wired up</h3>
        <div className="col-sm-6">
          <input type="hidden" id="export-results-ids" name="collection_ids" value="" />
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
    )
  }
})

export default Project
