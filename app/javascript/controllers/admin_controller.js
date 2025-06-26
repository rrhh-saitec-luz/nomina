import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin"
export default class extends Controller {
  static targets = ["tipoNomina", "nominaEspecifica", "links"]
  connect() {
	  console.log("Hello")
  }

  cargarInfo(e){
    const getValue = e.target.value
    const displayRender = this.renderDoTarget
    displayRender.innerHTML = `<%=${getValue}%>`
  }

  nominaEspecifica(evento){
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
  
  menu(evento){
    const enlaces = this.targets.findAll("links")
    enlaces.forEach(link => {
	link.classList.remove("list-group-item-primary")
      })
   console.log(this.linksTarget) 
  }
}
