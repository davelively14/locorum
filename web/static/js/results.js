let Results = {

  init(socket, element){ if(!element){ return }
    let searchId = element.getAttribute("data-id")
    socket.connect()
    this.onReady(searchId, socket)
  },

  onReady(searchId, socket){
    let resultsContainer = document.getElementById("results")
    let backendMenuContainer = document.getElementById("list_backends")
    let runSearch = document.getElementById("run-search")
    let searchChannel   = socket.channel("searches:" + searchId)

    runSearch.addEventListener("click", e => {
      searchChannel.push("run_search")
                   .receive("error", e => console.log(e) )
    })

    searchChannel.on("backend", (resp) => {
      this.renderBackend(resultsContainer, backendMenuContainer, resp)
    })

    searchChannel.on("result", (resp) => {
      let backendContainer = document.getElementById(resp.backend)
      this.renderResult(backendContainer, resp)
    })

    searchChannel.on("loaded_results", (resp) => {
      let backendMenuItem = document.getElementById(resp.backend + "_menu")
      backendMenuItem.innerHTML = `
      <a href="#${resp.backend}_header">${resp.backend_str}</a>
      `
    })

    searchChannel.on("no_result", (resp) => {
      let backendContainer = document.getElementById(resp.backend)
      this.renderNoResult(backendContainer)
    })

    searchChannel.on("clear_results", (resp) => {
      let resultsContainer = document.getElementById("results")
      let backendMenuContainer = document.getElementById("list_backends")

      resultsContainer.innerHTML = ``
      backendMenuContainer.innerHTML = ``
    })

    searchChannel.join()
      .receive("ok", resp => console.log("Joined search channel", resp))
      .receive("error", reason => console.log("Join failed", reason))

  },

  renderBackend(resultsContainer, backendMenuContainer, {backend, backend_str, backend_url, results_url, search_id}){
    let template = document.createElement("div")
    template.setAttribute("class", "panel panel-info")
    template.innerHTML = `
    <div class="panel-heading" id="${this.esc(backend)}_header">
    <h4><a href="${this.esc(backend_url)}" target="_blank">${this.esc(backend_str)}</a></h4>
    </div>
    <div class="panel-body" id="${this.esc(backend)}"></div>
    <div class="panel-footer">
    <a href="${this.esc(results_url)}" target="_blank">Go to results on ${this.esc(backend_str)}...</a>
    </div>
    `
    resultsContainer.appendChild(template)

    let new_result = document.createElement("div")
    new_result.setAttribute("id", backend + "_menu")
    new_result.innerHTML = `
    ${this.esc(backend_str)}...loading
    `
    backendMenuContainer.appendChild(new_result)
  },

  renderResult(backendContainer, {backend, biz, address, city, state, zip, rating, url, phone}){
    let template = document.createElement("div")

    // TODO refactor for short-circuit evaluation wihtin template innerHTML
    if (zip == null) {
      zip = ""
    }

    // TODO refactor to just add the last line if url is true
    if (url) {
      template.innerHTML = `
      <b>${this.esc(biz)}</b><br>
      ${this.esc(address)}<br>
      ${this.esc(city)}, ${this.esc(state)} ${this.esc(zip)}<br>
      ${this.esc(phone)}<br>
      <i>Rating: </i><b>${this.esc(rating)}</b><br>
      <i><a href="${this.esc(url)}" target="_blank">Edit entry</a></i><br>
      <br>
      `
    } else {
      template.innerHTML = `
      <b>${this.esc(biz)}</b><br>
      ${this.esc(address)}<br>
      ${this.esc(city)}, ${this.esc(state)} ${this.esc(zip)}<br>
      ${this.esc(phone)}<br>
      <i>Rating: </i><b>${this.esc(rating)}</b><br>
      <br>
      `
    }
    backendContainer.appendChild(template)
  },

  renderNoResult(backendContainer){
    let template = document.createElement("div")
    template.innerHTML = `
    <i>No results</i>
    `
    backendContainer.appendChild(template)
  },

  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  }
}
export default Results
