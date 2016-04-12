let Results = {

  init(socket, searchId){
    socket.connect()
    this.onReady(searchId, socket)
  },

  onReady(searchId, socket){
    let resultContainer = document.getElementById("result-container")
    let searchChannel   = socket.channel("searches:" + searchId)
    // TODO join the search channel
  }
}
export default Results

// init(){
//   let resName = document.getElementById("res-biz")
//   let postButton = document.getElementById("test-fill")
//
//   postButton.addEventListener("click", e => {
//     e.preventDefault()
//     let template = document.createElement("span")
//     resName.innerHTML = "<b>Lucas Group</b>"
//   })
// }
