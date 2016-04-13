let Results = {

  init(socket, searchId){
    socket.connect()
    this.onReady(searchId, socket)
  },

  onReady(searchId, socket){
    let resultContainer = document.getElementById("result-container")
    let searchChannel   = socket.channel("searches:" + searchId)
    // TODO join the search channel
  },
}
export default Results
