let Project = {

  init(socket, element){ if(!element){ return }
    let projectId = element.getAttribute("data-id")
    socket.connect()
    this.onReady(projectId, socket)
  },

  onReady(projectId, socket){
    let searchesContainer = document.getElementById("searches")
    let runSearch = document.getElementById("run-search")
    let dropdownTitle = document.getElementsByClassName("dropdown-menu-title")
    let loadingStatus = document.getElementsByClassName("load-status")
    let projectChannel = socket.channel("projects:" + projectId)

    runSearch.addEventListener("click", e => {
      this.showWebsiteDropdown(dropdownTitle)
      projectChannel.push("run_test")
                   .receive("error", e => console.log(e) )
    })

    projectChannel.on("backend", (resp) => {
      let loadedOf = document.getElementById(`search-${this.esc(resp.search_id)}-of`)
      loadedOf.innerHTML = parseInt(loadedOf.innerHTML) + 1
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

    projectChannel.on("loaded_results", (resp) => {
      let loaded = document.getElementById(`search-${this.esc(resp.search_id)}-loaded`)
      let loadedOf = document.getElementById(`search-${this.esc(resp.search_id)}-of`)
      let loadStatsContainer = document.getElementById(`load-status-${this.esc(resp.search_id)}`)
      loaded.innerHTML = parseInt(loaded.innerHTML) + 1
      if (loaded.innerHTML == loadedOf.innerHTML) {
        loadStatsContainer.setAttribute("class", "text-success")
        loadStatsContainer.innerHTML = "Loaded all " + loaded.innerHTML + " backends"
      }
    })

    projectChannel.join()
      .receive("ok", resp => console.log("Joined project channel", resp))
      .receive("error", resp => console.log("Failed to join project channel", resp))
  },

  renderBackend(resp){
    let dropMenu = document.getElementById(`backendDrop${resp.search_id}-contents`)
    let dropMenuBackend = document.createElement("li")
    dropMenuBackend.innerHTML = `
    <a href="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}" role="tab" id="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}-tab" data-toggle="tab" aria-controls="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}" aria-expanded="false">${this.esc(resp.backend_str)} <span class="badge" id="${this.esc(resp.backend)}-${this.esc(resp.search_id)}-badge">0</span></a>
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
    let counter = document.getElementById('id')
    newContent.setAttribute("class", "col-sm-12 col-md-6 col-lg-4")
    if(resp.url){
      newContent.innerHTML = `
      <div class="panel panel-info">
      <div class="panel-body">
      <b>${this.esc(resp.biz)}</b><br>
      ${this.esc(resp.address)}<br>
      ${this.esc(resp.city)}, ${this.esc(resp.state)} ${this.esc(resp.zip || "")}<br>
      ${this.esc(resp.phone)}<br>
      <i>Rating: <b>${this.esc(resp.rating)}</b></i>
      </div>
      <div class="panel-footer">
      <i><a href="${this.esc(resp.url)}" target="_blank">Edit entry</a></i>
      </div>
      </div>`
    } else {
      newContent.innerHTML = `
      <div class="panel panel-info">
      <div class="panel-body">
      <b>${this.esc(resp.biz)}</b><br>
      ${this.esc(resp.address)}<br>
      ${this.esc(resp.city)}, ${this.esc(resp.state)} ${this.esc(resp.zip || "")}<br>
      ${this.esc(resp.phone)}<br>
      <i>Rating: <b>${this.esc(resp.rating)}</b></i>
      </div>`
    }

    dropContent.appendChild(newContent)

    let badgeCounter = document.getElementById(`${this.esc(resp.backend)}-${this.esc(resp.search_id)}-badge`)
    if (parseInt(resp.rating) > parseInt(badgeCounter.innerHTML)){
      badgeCounter.innerHTML = this.esc(resp.rating)
    }
  },

  renderNoResult(resp){
    let dropContent = document.getElementById(`dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}`)
    let newContent = document.createElement("div")
    newContent.innerHTML = `
    <i>No results</i>
    `
    dropContent.appendChild(newContent)
  },

  showWebsiteDropdown(dropdownTitle){
    Array.prototype.forEach.call(dropdownTitle, function(elem){
      elem.setAttribute("class", "dropdown dropdown-menu-title")
    })
  },

  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  }
}


export default Project
