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
      projectChannel.push("run_search")
                   .receive("error", e => console.log(e) )
    })

    // Need search_id for this one...
    projectChannel.on("backend", (resp) => {
      this.renderBackend(resp)
    })

    projectChannel.on("result", (resp) => {
      this.renderResult(resp)
    })

    projectChannel.on("no_result", (resp) => {
      this.renderNoResult(resp)
    })

    projectChannel.on("clear_results", (resp) => {
      let dropdownElements = document.getElementsByClassName("backend-titles")
      let tabElements = document.getElementsByClassName("backend-content")
      let overviewElements = document.getElementsByClassName("search-result-tabs")

      Array.prototype.forEach.call(dropdownElements, function(elem){
        elem.innerHTML = ""
      })
      Array.prototype.forEach.call(tabElements, function(elem){
        let firstChild = elem.children[0]
        firstChild.setAttribute("class", "tab-pane fade in active")
        elem.innerHTML = ""
        elem.appendChild(firstChild)
      })
      Array.prototype.forEach.call(overviewElements, function(elem){
        elem.children[0].setAttribute("class", "active")
        elem.children[1].setAttribute("class", "dropdown")
      })
    })

    projectChannel.join()
      .receive("ok", resp => console.log("Joined project channel", resp))
      .receive("error", resp => console.log("Failed to join project channel", resp))
  },

  renderBackend(resp){
    let dropMenu = document.getElementById(`backendDrop${resp.search_id}-contents`)
    let dropMenuBackend = document.createElement("li")
    dropMenuBackend.innerHTML = `
    <a href="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}" role="tab" id="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}-tab" data-toggle="tab" aria-controls="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}" aria-expanded="false">${this.esc(resp.backend_str)}</a>
    `
    dropMenu.appendChild(dropMenuBackend)

    let tabContent = document.getElementById(`tab-content-${this.esc(resp.search_id)}`)
    let tabContentBackend = document.createElement("div")
    tabContentBackend.setAttribute("class", "tab-pane fade")
    tabContentBackend.setAttribute("role", "tabpanel")
    tabContentBackend.setAttribute("id", `dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}`)
    tabContentBackend.innerHTML = `<h4>${this.esc(resp.backend_str)} <small><a href="${this.esc(resp.results_url)}" target="_blank" class="pull-right">view results in new tab</a></small></h4>`
    tabContent.appendChild(tabContentBackend)
  },

  renderResult(resp){
    let dropContent = document.getElementById(`dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}`)
    let newContent = document.createElement("div")
    newContent.innerHTML = `
    <b>${this.esc(resp.biz)}</b><br>
    ${this.esc(resp.address)}<br>
    ${this.esc(resp.city)}, ${this.esc(resp.state)} ${this.esc(resp.zip || "")}<br>
    ${this.esc(resp.phone)}<br>
    <i>Rating: <b>${this.esc(resp.rating)}</b><br>`

    if(resp.url){
      newContent.innerHTML = newContent.innerHTML + `<i><a href="${this.esc(resp.url)}" target="_blank">Edit entry</a></i><br><br>`
    }

    dropContent.appendChild(newContent)
  },

  renderNoResult(resp){
    let dropContent = document.getElementById(`dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}`)
    let newContent = document.createElement("div")
    newContent.innerHTML = `
    <i>No results</i>
    `
    dropContent.appendChild(newContent)
  },

  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  }
}


export default Project
