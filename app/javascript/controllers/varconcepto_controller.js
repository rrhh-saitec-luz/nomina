import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="varconcepto"
export default class extends Controller {
  static targets = ["codigoselecto",
	  	    "descripcionselecto",
	  	    "tiponomina",
  		    "nominaespecifica",
  		    "estatusConcepto",
  		    "indicadorPago",
  		    "inidiceNomina" ]
  seleccionar(){
    const selecto = this.codigoselectoTarget.value
    const opcionselecta = this.codigoselectoTarget.options[this.codigoselectoTarget.selectedIndex]
    const description = opcionselecta.dataset.descripcion
    const estatus = opcionselecta.dataset.estatus
    const indicador = opcionselecta.dataset.indc
    const indicadorPago = document.getElementById("variacion_indicador_de_pago") 
    this.descripcionselectoTarget.value = description
    this.estatusConceptoTarget.value = estatus
    indicadorPago.value = indicador
 } 

  cargarNominaEspecifica(e){
    const tipoNominaId = e.target.value
    fetch(`/variacions/nomina_espc_tipos.json?tipo_nomina=${tipoNominaId}`)
	.then(response => response.json())
	.then(datos => {
	  const cargarNominaEspc = this.nominaespecificaTarget
	  cargarNominaEspc.innerHTML = "<option value =''>Nomina especifica</option>"
	  datos.forEach(nomina =>{
	    const option = document.createElement('option');
	    option.value = nomina.tipo_nomina_especifica;
	    option.textContent = nomina.descripcion;
	    cargarNominaEspc.appendChild(option);
	  });
	});
  }

}
