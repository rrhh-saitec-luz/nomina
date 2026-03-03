// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"
// Si usas importmaps, asegúrate de que bootstrap esté disponible globalmente
// Si usas esbuild/webpack: import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    // Creamos la instancia
    this.modal = new bootstrap.Modal(this.element)
    this.modal.show()
  }

  // Se ejecuta automáticamente cuando Turbo quita el elemento del DOM
  disconnect() {
    this.modal.hide()
    
    // Limpieza manual del backdrop si Bootstrap lo deja olvidado
    const backdrop = document.querySelector('.modal-backdrop')
    if (backdrop) backdrop.remove()
    
    // Limpieza de clases en el body para permitir scroll
    document.body.classList.remove('modal-open')
    document.body.style.removeProperty('padding-right')
    document.body.style.removeProperty('overflow')
  }

  // Método para cerrar manualmente desde botones de "Cerrar"
  cerrar() {
    this.modal.hide()
  }
}
