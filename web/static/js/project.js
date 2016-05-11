let Project = {

  init(socket, element){ if(!element){ return }
    let projectId = element.getAttribute("data-id")
    socket.connect()
    this.onReady(projectId, socket)
  },

  onReady(projectId, socket){
    let searchesContainer = document.getElementById("searches")
    let runSearch = document.getElementById("run-search")
    let projectChannel = socket.channel("projects:" + projectId)

    runSearch.addEventListener("click", e => {
      projectChannel.push("run_test")
                   .receive("error", e => console.log(e) )
    })

    // Need search_id for this one...
    projectChannel.on("backend", (resp) => {
      this.renderBackend(resp)
    })

    projectChannel.join()
      .receive("ok", resp => console.log("Joined project channel", resp))
      .receive("error", resp => console.log("Failed to join project channel", resp))
  },

  renderBackend(resp){
    let template = document.createElement("div")
  },

  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  }
}


export default Project
