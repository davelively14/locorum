let Results = {

  init(socket, element){ if(!element){ return }
    let searchId = element.getAttribute("data-id")
    socket.connect()
    this.onReady(searchId, socket)
  },

  onReady(searchId, socket){
    let resultContainer = document.getElementById("result-container")
    let searchChannel   = socket.channel("searches:" + searchId)

    searchChannel.join()
      .receive("ok", resp => console.log("Joined searchChannel", resp))
      .receive("error", resp => console.log("Join failed", reason))

    searchChannel.on("ping", ({count}) => console.log("PING", count))
  },
}
export default Results
