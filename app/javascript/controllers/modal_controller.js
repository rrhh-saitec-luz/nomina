import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Inicializamos solo si el elemento existe
    if (this.element) {
      this.modal = new bootstrap.Modal(this.element)
      this.modal.show()
    }
  }

  disconnect() {
    try {
      if (this.modal) {
        // Primero ocultamos rápido
        this.modal.hide()
        // Luego destruimos la instancia para liberar memoria
        this.modal.dispose()
      }
    } catch (error) {
      // Silenciamos el error de Bootstrap porque el elemento ya no está en el DOM
      console.log("Bootstrap intentó acceder a un elemento ya removido por Turbo.")
    } finally {
      // Pase lo que pase, limpiamos el body y el backdrop
      this.cleanup()
    }
  }

  cerrar() {
    if (this.modal) {
      this.modal.hide()
    }
  }

  cleanup() {
    // Eliminamos cualquier rastro visual
    document.querySelectorAll('.modal-backdrop').forEach(el => el.remove())
    document.body.classList.remove('modal-open')
    document.body.style.removeProperty('padding-right')
    document.body.style.removeProperty('overflow')
  }
}

