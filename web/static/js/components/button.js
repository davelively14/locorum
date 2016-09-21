import React from 'react'

// Button component.
// btn_class: string, takes the class paramters to be used by the button.
//            Default is "btn btn-primary"
// content: string, this is the text to be displayed in the button. Default is
//          "No content"
// visible: string/boolean, if set to "false" or false, will append " hidden" to
//          the btn_class string. No default value.
// action: function, callback function for onClick action. No default.
const Button = React.createClass({
  render() {
    var btn_class = this.props.btn_class || "btn btn-primary"
    var content = this.props.content || "No content"
    var type = this.props.type || "button"

    if (this.props.visible == "false" || this.props.visible == false) {
      btn_class = btn_class + " hidden"
    }

    return (
      <span>
        <input className={btn_class} type={type} value={content} onClick={this.props.action} />
      </span>
    )
  }
})

export default Button
