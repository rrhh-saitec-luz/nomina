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
	  	    "saldoContent",
  		    "saldo",
  		    "mes",
  		    "ano",
  		    "indiceConcepto",
  		    "indicadorReal",
  		    "salarioContent",
  		    "salario"]
  connect() {
  }
  seleccionar(){
    const opciones = {
	    M: "MONTO",
	    C: "CANTIDAD",
	    P: "PORCENTAJE"
    }
    const opcionselecta = this.codigoselectoTarget.options[this.codigoselectoTarget.selectedIndex]
    const description = opcionselecta.dataset.descripcion
    const estatus = opcionselecta.dataset.estatus
    const indicador = opcionselecta.dataset.indicador
    const montoFijo = opcionselecta.dataset.monto
    const operacion = opcionselecta.dataset.operacion
    const indice = opcionselecta.dataset.indice
    const indicadorPago = this.indicadorPagoTarget 
    const montoConceptoPrevio = this.montoPrevioTarget
    const saldoContent = this.saldoContentTarget
    const saldo = this.saldoTarget
    const subTotal = this.subTotalTarget
    const salarioBaseContent = this.salarioContentTarget
    const salario = this.salarioTarget
    this.descripcionselectoTarget.value = description
    this.estatusConceptoTarget.value = estatus
    this.indicadorPagoTarget.value = indicador
    this.indiceConceptoTarget.value = indice
    this.indicadorRealTarget.value = indicador
    indicadorPago.value = opciones[indicador]
    montoConceptoPrevio.value = montoFijo
    if(indicadorPago.value == "CANTIDAD"){
      saldoContent.classList.remove("d-none")
      salarioBaseContent.classList.add("d-none")
    }else if(indicadorPago.value == "PORCENTAJE"){
      saldoContent.classList.add("d-none")
      salarioBaseContent.classList.remove("d-none")
    }else{
      saldoContent.classList.add("d-none")
      salarioBaseContent.classList.add("d-none")
    }
    saldo.value =  "0.0"
    salario.value = "0.0"
    subTotal.value = montoFijo 
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
	    option.textContent = nomina.descripcion
	    cargarNominaEspc.appendChild(option);
	  });
	})
        .catch(error => {
          console.error('Error al cargar los datos:', error);
        });
  }
  
  calculoMontoSaldo(e){
    const obtenerIndicador = this.indicadorPagoTarget.value
    const montoConceptoPrevio = this.montoPrevioTarget.value     
    const montoSaldo = parseFloat(e.target.value)
    const montoPrev = parseFloat(montoConceptoPrevio)
    const accion = ""
    if(obtenerIndicador == "PORCENTAJE"){
      const subTotal = (montoPrev * montoSaldo)/100 
      this.subTotalTarget.value = subTotal
    }else{
      const  subTotal = (montoPrev * montoSaldo) 
      this.subTotalTarget.value = subTotal
    }
  }
  calculoMontoConcepto(){
    const montoSub = this.subTotalTarget
    const montoConcepto = this.montoPrevioTarget.value
    montoSub.value = montoConcepto
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
  action(e){
    console.log(e.target.value)
    console.log(tipoNomina)
  }
}
