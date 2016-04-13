let Results = {

  init(socket, element){ if(!element){ return }
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
