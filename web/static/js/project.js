let Project = {

  init(socket, element){ if(!element){ return }
    let projectId = element.getAttribute("data-id")
    socket.connect()
    this.onReady(projectId, socket)
  },

  onReady(projectId, socket){
    let runSearchBtn = document.getElementById("run-search")
    let exportResultsBtn = document.getElementById("export-results")
    let runSingleSearch = document.getElementsByClassName("run-single-search")
    let loadingStatus = document.getElementsByClassName("load-status")
    let projectChannel = socket.channel("projects:" + projectId)

    runSearchBtn.addEventListener("click", e => {
      e.preventDefault()
      this.clearAndPrepAllResults()
      projectChannel.push("run_search")
                   .receive("error", e => console.log(e) )
    })

    exportResultsBtn.addEventListener("click", e => {
      // e.preventDefault()
      let hiddenInput = document.getElementById("export-results-ids")
      let payload = Project.getListedCollections()
      hiddenInput.setAttribute("value", payload)
      // console.log(payload)
      // projectChannel.push("export_results", payload)
      //               .receive("error", e => console.log(e))
    })

    Array.prototype.forEach.call(runSingleSearch, function(button){
      button.addEventListener("click", e => {
        let search_id = button.getAttribute("data-id")
        let payload = {search_id: search_id}
        Project.clearAndPrepSingleResult(search_id)
        projectChannel.push("run_single_search", payload)
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

    projectChannel.on("render_collection", (resp) => {
      if (resp) {
        Project.clearAndPrepSingleResult(resp.collection.search_id)
        Project.renderCollection(resp.collection)
      } else {
        console.log("no results from collection to render")
      }
    })

    projectChannel.join()
      .receive("ok", resp => {
        if (resp) {
          Project.clearAndPrepAllResults()
          resp.collections.forEach(function(collection){
            Project.renderCollection(collection)
          })
          Project.addCollectionListData(resp.collection_list, projectChannel)
        } else {
          console.log("joined, channel empty")
        }

      })

      .receive("error", resp => console.log("Failed to join project channel", resp))
  },

  clearAndPrepAllResults(){
    let dropdownElements = document.getElementsByClassName("backend-titles")
    let tabContentElements = document.getElementsByClassName("backend-content")
    let overviewElements = document.getElementsByClassName("search-result-tabs")
    let loadStatusElements = document.getElementsByClassName("load-status")
    let dropdownTitle = document.getElementsByClassName("dropdown-menu-title")
    let runSearchBtn = document.getElementById("run-search")
    let exportResultsBtn = document.getElementById("export-results")

    runSearchBtn.innerHTML = "Rerun All Searches"
    console.log("Export Results Button Class Attribute: " + exportResultsBtn.getAttribute("class"));
    exportResultsBtn.setAttribute("class", "btn btn-primary btn-block")

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
    tabContentBackend.innerHTML = `<h4>${this.esc(resp.backend_str)} <small><a href="${this.esc(resp.url)}" target="_blank" class="pull-right">view results in new tab</a></small></h4>`
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
      <i><a href="${this.esc(resp.url)}" target="_blank">View at source</a></i>
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

    // TODO can I write this in ES6 instead of jquery? Shows tab for new backend
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

  addCollectionListData(collectionList, projectChannel){
    // TODO handle excessive amount of result_collections (more than 5)
    collectionList.forEach(function(collection){
      let selectCollection = document.getElementById(`select-collection-${collection.search_id}`)
      let newElement = document.createElement("li")
      newElement.innerHTML = `
      <a href="" data-id="${collection.result_collection_id}">${selectCollection.children.length - 1}: ${collection.created}</a>
      `
      selectCollection.appendChild(newElement)
      newElement.addEventListener("click", e => {
        e.preventDefault()
        let payload = new Object()
        let title = selectCollection.parentElement.firstElementChild
        title.innerHTML = `
        From ${collection.created} <span class="caret"></span>
        `
        payload.collection_id = collection.result_collection_id
        projectChannel.push("fetch_collection", payload)
      })
    })
  },

  renderCollection(collection){
    let loaded = document.getElementById(`search-${Project.esc(collection.search_id)}-loaded`)
    let loadStatsContainer = document.getElementById(`load-status-${Project.esc(collection.search_id)}`)
    let searchTag = document.getElementById(`search-results-${collection.search_id}`)
    let loadedBackends = {}

    searchTag.setAttribute("collection-id", collection.id)

    collection.results.forEach(function(result){
      result.search_id = collection.search_id

      if (loadedBackends[result.backend] == null) {
        Project.renderBackend(result)
        loadedBackends[result.backend] = {}
        loadedBackends[result.backend].total = 1
        loadedBackends[result.backend].backend_str = result.backend_str
        loadedBackends[result.backend].high_rating = result.rating
        loadedBackends[result.backend].low_rating = result.rating
      } else {
        loadedBackends[result.backend].total = loadedBackends[result.backend].total + 1
        if (result.rating > loadedBackends[result.backend].high_rating) {
          loadedBackends[result.backend].high_rating = result.rating
        } else if (result.rating < loadedBackends[result.backend].low_rating) {
          loadedBackends[result.backend].low_rating = result.rating
        }
      }
      Project.renderResult(result)
    })

    loadStatsContainer.setAttribute("class", "text-success load-status")
    loadStatsContainer.innerHTML = "Loaded all " + Object.keys(loadedBackends).length + " backends"

    // TODO should make this Collection -> Backends -> Results in the structure. Long term refactor for simplification

    for (var key in loadedBackends) {
      let finalTally = {}

      finalTally.backend = key
      finalTally.backend_str = loadedBackends[key].backend_str
      finalTally.search_id = collection.search_id
      finalTally.num_results = loadedBackends[key].total
      finalTally.high_rating = loadedBackends[key].high_rating
      finalTally.low_rating = loadedBackends[key].low_rating

      Project.renderTally(finalTally)
    }
  },

  getListedCollections(){
    let elementsList = document.getElementsByClassName("search-box")
    let collectionIDs = []
    for (var i = 0; i < elementsList.length; i++) {
      collectionIDs.push(elementsList[i].getAttribute("collection-id"))
    }
    return collectionIDs
  },

  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  }
}


export default Project
