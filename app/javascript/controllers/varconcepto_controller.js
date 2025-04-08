import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="varconcepto"
export default class extends Controller {
  static targets = ["codigoselecto", "descripcionselecto"]
  seleccionar(){
    const selecto = this.codigoselectoTarget.value
    const opcionselecta = this.codigoselectoTarget.options[this.codigoselectoTarget.selectedIndex]
    const description = opcionselecta.dataset.descripcion
    this.descripcionselectoTarget.value = description
 } 
}
