import React from 'react'

const Button = React.createClass({
  render() {
    var btn_class = this.props.btn_class || "btn btn-primary"
    var content = this.props.content || "No content"

    if (this.props.visible == "false" || this.props.visible == false) {
      btn_class = btn_class + " hidden"
    }

    return (
      <span>
        <input className={btn_class} type="button" value={content} onClick={this.props.action} />
      </span>
    )
  }
})

export default Button
