class TabTrabajadorsController < ApplicationController
  DESCRIPCION_DE_ESTADOS = { 'A' => 'ACTIVO',
                             'F' => 'FALLECIDO',
                             'S' => 'SUSPENDIDO',
                             'R' => 'RETIRADO',
                             'P' => 'PENSIONADO',
                             'T' => 'PENSIONADO',
                             'C' => 'CONTRATADO' }.freeze

  DESCRIPCION_PRINCIPAL = { 'S' => 'SI', 'N' => 'NO' }.freeze

  def index
    @trabajadores = TabTrabajador.all
    @search_term = params[:q]
    @desc_estatus = DESCRIPCION_DE_ESTADOS

    if @search_term.present?
      @sidial = Admon.where('ce_trabajador::text ILIKE ?', "%#{@search_term}%")
                     .page(params[:page]).per(10)
    else
      @sidial = nil
    end
  end

  def new
    @nuevo = TabTrabajador.new
  end

  def show
    @trabajador = Admon.find(params[:id])
    @desc_estatus = DESCRIPCION_DE_ESTADOS
    @desc_principal = DESCRIPCION_PRINCIPAL
    @antiguedad = calculo_de_antiguedad(@trabajador)
    @turno = params[:fecha]
    @fechas_estatus_cargo = fechas_gral_cargo(@trabajador)
  end

  def create
    @nuevo = TabTrabajador.new(nuevo_ingreso_params)

    if @nuevo.save
      redirect_to tab_trabajadors_index_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def nuevo_ingreso_params
    params.permit(:cedula, :nombre1, :nombre2, :apellido1, :apellido2, :fecha_de_nac)
  end

  def calculo_de_antiguedad(trabajador)
    fecha_final = check_fecha_final(trabajador)
    fecha_inicio = trabajador.fe_ingreso
    fechas = [fecha_final, fecha_inicio]

    return 0 if fecha_inicio.year == fecha_final.year

    antiguedad = fecha_final.year - fecha_inicio.year

    if check_month?(fechas) || (fecha_final.month == fecha_inicio.month && fecha_final.day < fecha_inicio.day)
      antiguedad -= 1
    end

    antiguedad
  end

  def check_month?(fechas)
    fechas[0].month < fechas[1].month
  end

  def check_fecha_final(trabajador)
    return trabajador.fe_efectiva unless trabajador.fe_efectiva.nil?
    return trabajador.fe_jubilacion unless trabajador.fe_jubilacion.nil?
    return trabajador.retiro_efectivo unless trabajador.retiro_efectivo.nil?

    Date.today
  end

  def fechas_gral_cargo(trabajador)
    {  'Ingreso a LUZ' => trabajador.fe_ingreso,
       'Ingreso Nómina' => trabajador.fe_ingreso_nomina,
       'Jubilación/Pensión' => trabajador.fe_jubilacion,
       'Retiro Efectivo ' => trabajador.fe_retiro,
       'Retiro Nómina' => trabajador.fe_retiro,
       'Fecha de Finiquito' => nil,
       'Fallecimiento' => trabajador.fe_efectiva2 }
  end
end
