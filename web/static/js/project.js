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
      let temp = document.getElementById("title-header")
      temp.innerHTML = `
      Test underway...
      `
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
    let dropMenu = document.getElementById(`backendDrop${resp.search_id}-contents`)
    let newBackend = document.createElement("li")
    newBackend.innerHTML = `
    <a href="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}" role="tab" id="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}-tab" data-toggle="tab" aria-controls="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}" aria-expanded="false">${this.esc(resp.backend_str)}</a>
    `
    dropMenu.appendChild(newBackend)
    let temp = document.getElementById("title-header")
    temp.innerHTML = newBackend.innerHTML
  },

  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  }
}


export default Project
