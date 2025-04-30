import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="varconcepto"
export default class extends Controller {
  static targets = ["codigoselecto",
	  	    "descripcionselecto",
	  	    "tiponomina",
  		    "nominaespecifica",
  		    "estatusConcepto",
  		    "indicadorPago",
  		    "inidiceNomina",
	  	    "montoPrevio",
  		    "subTotal",
  		    "saldo",
  		    "mes",
  		    "ano",
  		    "indiceConcepto" ]
  seleccionar(){
    const opciones = {
	    M: "MONTO",
	    C: "CANTIDAD",
	    P: "PORCENTAJE"
    }
    const selecto = this.codigoselectoTarget.value
    const opcionselecta = this.codigoselectoTarget.options[this.codigoselectoTarget.selectedIndex]
    const description = opcionselecta.dataset.descripcion
    const estatus = opcionselecta.dataset.estatus
    const indicador = opcionselecta.dataset.indc
    const montoFijo = opcionselecta.dataset.monto
    const operacion = opcionselecta.dataset.operacion
    const indice = opcionselecta.dataset.indice
    const indicadorPago = this.indicadorPagoTarget 
    const montoConceptoPrevio = this.montoPrevioTarget
    const saldo = this.saldoTarget
    const subTotal = this.subTotalTarget
    this.descripcionselectoTarget.value = description
    this.estatusConceptoTarget.value = estatus
    this.indicadorPagoTarget.value = indicador
    this.indiceConceptoTarget.value = indice
    indicadorPago.value = opciones[indicador]
    montoConceptoPrevio.value = montoFijo
    saldo.value =  "0.0"
    subTotal.value = "0.0"
    
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
  
  calculo(e){
    const montoConceptoPrevio = this.montoPrevioTarget.value     
    const montoSaldo = parseFloat(e.target.value)
    const montoPrev = parseFloat(montoConceptoPrevio)
    const subTotal = montoSaldo * montoPrev 
    this.subTotalTarget.value = subTotal
  }

  actualizarFecha(e){
    const fecha = e.target.value
    if(fecha){
      const date = new Date(fecha)
      const month = date.getMonth() + 1
      const year = date.getFullYear()  
      const formattedMonth = month.toString().padStart(2, '0')
      this.mesTarget.value = parseInt(formattedMonth)
      this.anoTarget.value = parseInt(year)
    }
  }
}
