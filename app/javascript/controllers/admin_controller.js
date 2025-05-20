import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin"
export default class extends Controller {
  static targets = ["genNomina", "renderDo"]
  connect() {
	  console.log("Hello")
  }

  cargarInfo(e){
    console.log(e.target.value)
    const getValue = e.target.value
    const displayRender = this.renderDoTarget
    displayRender.innerHTML = `<%=${getValue}%>`
  }
}
