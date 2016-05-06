let Project = {

  init(socket, element){ if(!element){ return }
    let projectId = element.getAttribute("data-id")
    socket.connect()
    this.onRead(projectId, socket)
  },

  onReady(projectId, socket){
    let searchesContainer = document.getElementById("searches")
  }
}


export default Project
