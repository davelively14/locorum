let Project = {

  init(socket, element){ if(!element){ return }
    let projectId = element.getAttribute("data-id")
    socket.connect()
    this.onReady(projectId, socket)
  },

  onReady(projectId, socket){
    let searchesContainer = document.getElementById("searches")
    let runProjectSearch = document.getElementById("run-search")
    let runSingleSearch = document.getElementsByClassName("run-single-search")
    let loadingStatus = document.getElementsByClassName("load-status")
    let projectChannel = socket.channel("projects:" + projectId)

    runProjectSearch.addEventListener("click", e => {
      this.clearAndPrepAllResults()
      projectChannel.push("run_test")
                   .receive("error", e => console.log(e) )
    })

    Array.prototype.forEach.call(runSingleSearch, function(button){
      button.addEventListener("click", e => {
        let search_id = button.getAttribute("data-id")
        let payload = {search_id: search_id}
        Project.clearAndPrepSingleResult(search_id)
        projectChannel.push("run_single_test", payload)
                      .receive("error", e => console.log(e) )
      })
    })

    projectChannel.on("backend", (resp) => {
      // TODO just populate with all backends...eliminates "no results" error
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

    projectChannel.on("loaded_results", (resp) => {
      let loaded = document.getElementById(`search-${this.esc(resp.search_id)}-loaded`)
      let loadedOf = document.getElementById(`search-${this.esc(resp.search_id)}-of`)
      let loadStatsContainer = document.getElementById(`load-status-${this.esc(resp.search_id)}`)
      loaded.innerHTML = parseInt(loaded.innerHTML) + 1
      if (loaded.innerHTML == loadedOf.innerHTML) {
        loadStatsContainer.setAttribute("class", "text-success load-status")

        loadStatsContainer.innerHTML = "Loaded all " + loaded.innerHTML + " backends"
      }
      this.renderTally(resp)
    })

    projectChannel.join()
      .receive("ok", resp => {
        console.log("Joined", resp)

      })

      .receive("error", resp => console.log("Failed to join project channel", resp))
  },

  clearAndPrepAllResults(){
    let dropdownElements = document.getElementsByClassName("backend-titles")
    let tabContentElements = document.getElementsByClassName("backend-content")
    let overviewElements = document.getElementsByClassName("search-result-tabs")
    let loadStatusElements = document.getElementsByClassName("load-status")
    let dropdownTitle = document.getElementsByClassName("dropdown-menu-title")

    this.showWebsiteDropdown(dropdownTitle)
    this.prepOverviews()

    Array.prototype.forEach.call(dropdownElements, function(elem){
      elem.innerHTML = ""
    })
    Array.prototype.forEach.call(tabContentElements, function(elem){
      let overviewTab = elem.children[0]
      overviewTab.setAttribute("class", "tab-pane fade in active overview")
      elem.innerHTML = ""
      elem.appendChild(overviewTab)
    })
    Array.prototype.forEach.call(overviewElements, function(elem){
      elem.children[0].setAttribute("class", "active")
      elem.children[1].setAttribute("class", "dropdown")
    })

    Array.prototype.forEach.call(loadStatusElements, function(elem){
      let id = elem.getAttribute("id").split(/[\s-]+/).pop()
      elem.innerHTML = `Loaded <span id="search-${id}-loaded">0</span> of <span id="search-${id}-of">0</span> backends`
    })
  },

  clearAndPrepSingleResult(search_id){
    let dropdownElement = document.getElementById(`backendDrop${search_id}-contents`)
    let tabContentElement = document.getElementById(`tab-content-${search_id}`)
    let overviewElement = document.getElementById(`search-result-tabs-${search_id}`)
    let loadStatusElement = document.getElementById(`load-status-${search_id}`)

    dropdownElement.innerHTML = ""

    let overviewTab = tabContentElement.children[0]
    overviewTab.setAttribute("class", "tab-pane fade in active overview")
    tabContentElement.innerHTML = ""
    tabContentElement.appendChild(overviewTab)
    overviewTab.innerHTML = `
    <table id="overview-${search_id}-table" class="table table-hover">
    <tr>
    <th>Backend</th>
    <th>Results</th>
    <th>High Rating</th>
    <th>Low Rating</th>
    </tr>
    </table>
    `

    overviewElement.children[0].setAttribute("class", "active")
    overviewElement.children[1].setAttribute("class", "dropdown")

    loadStatusElement.innerHTML = `Loaded <span id="search-${search_id}-loaded">0</span> of <span id="search-${search_id}-of">0</span> backends`


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
  },

  renderTally(resp){
    let badgeCounter = document.getElementById(`${this.esc(resp.backend)}-${this.esc(resp.search_id)}-badge`)
    badgeCounter.innerHTML = `${this.esc(resp.num_results)}`

    let tallyContainerTable = document.getElementById(`overview-${this.esc(resp.search_id)}-table`)
    let newEntry = document.createElement("tr")
    newEntry.innerHTML = `
    <td><a href="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}" role="tab" data-toggle="tab" aria-controls="#dropdown-${this.esc(resp.backend)}-${this.esc(resp.search_id)}">${this.esc(resp.backend_str)}</a></td>
    <td>${this.esc(resp.num_results)}</td>
    <td>${this.esc(resp.high_rating || "--")}</td>
    <td>${this.esc(resp.low_rating || "--")}</td>
    `
    tallyContainerTable.children[0].appendChild(newEntry)

    // TODO can I write this in ES6 instead of jquery?
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
      var target = this.href.split('#');
      $('.nav a').filter('a[href="#'+target[1]+'"]').tab('show');
    })
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

  prepOverviews(){
    let allOverviews = document.getElementsByClassName("overview")
    Array.prototype.forEach.call(allOverviews, function(elem){
      let parentId = elem.getAttribute("id")
      elem.innerHTML = `
      <table id="${parentId}-table" class="table table-hover">
        <tr>
          <th>Backend</th>
          <th>Results</th>
          <th>High Rating</th>
          <th>Low Rating</th>
        </tr>
      </table>
      `
    })
  },

  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  }
}


export default Project
