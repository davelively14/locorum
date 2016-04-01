let Results = {
  init(){
    let resName = document.getElementById("res-biz")
    let postButton = document.getElementById("test-fill")

    postButton.addEventListener("click", e => {
      e.preventDefault()
      let template = document.createElement("span")
      resName.innerHTML = "<b>Lucas Group</b>"
    })
  }
}
export default Results
