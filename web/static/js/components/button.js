import React from 'react'

const Button = React.createClass({
  // TODO the button has to listen for a click after mounting and then perform some action. Not sure how to define that action yet. Pass a function call?

  render() {
    var btn_class = this.props.btn_class || "btn btn-primary"
    var content = this.props.content || "No content"

    if (this.props.visible == "false" || this.props.visible == false) {
      btn_class = btn_class + " hidden"
    }
    return (
      <span>
        <input className={btn_class} type="submit" value={content} />
      </span>
    )
  }
})

export default Button
