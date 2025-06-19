import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin"
export default class extends Controller {
  static targets = ["tipoNomina", "nominaEspecifica"]
  connect() {
	  console.log("Hello")
  }

  cargarInfo(e){
    console.log(e.target.value)
    const getValue = e.target.value
    const displayRender = this.renderDoTarget
    displayRender.innerHTML = `<%=${getValue}%>`
  }
  nominaEspecifica(evento){
    console.log(evento.target.value)
    const tipoNominaId = evento.target.value
    fetch(`/variacions/nomina_espc_tipos.json?tipo_nomina=${tipoNominaId}`)
	.then(response => response.json())
	.then(datos => {
	  const cargarNominaEspc = this.nominaEspecificaTarget
	  cargarNominaEspc.innerHTML = "<option value =''> Seleccione opción</option>"
	  datos.forEach(nomina =>{
	    const option = document.createElement('option');
	    option.value = nomina.tipo_nomina_especifica;
	    option.textContent = nomina.descripcion
	    cargarNominaEspc.appendChild(option);
	  });
	})
        .catch(error => {
          console.error('Error al cargar los datos:', error);
        });
  }
}
