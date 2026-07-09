# Frozen_string_literal: true

# Clase para manejar las variaciones
class VariacionsController < ApplicationController
  include Constantes
  def index; end

  def show
    @trab = Admon.find(params[:id])
    @presenter = TrabajadorPresenter.new(@trab)
  end

  def new
    @trab = Admon.find(params[:id])
    @variacion = Variacion.new
    @con = Listado.all
    @tipo_nomina = NominaTipo.all
    @estatus = estatus(@trab)
  end

  def nomina_espc_tipos
    @nomina_especifica = NominaEspecifica.where(tipo_nomina: params[:tipo_nomina])
    respond_to do |format|
      format.json { render json: @nomina_especifica }
    end
  end

  def create
    @trab = Admon.find(params[:variacion][:id_trabajador])
    @variacion = Variacion.new(variacion_params_completos)

    # 3. Asignamos los campos de auditoría exclusivos de Variacion
    @variacion.usuario = current_user&.nombre
    @variacion.status  = false

    # 4. Construimos el HistoricoPago extrayendo los datos desde el objeto @variacion
    @historico_pago = HistoricoPago.new(
      CE_TRABAJADOR: @variacion.ce_trabajador,
      CO_UBICACION: @variacion.co_ubicacion,
      TIPOPERSONAL: @variacion.tipopersonal,
      CO_CONCEPTO: @variacion.co_concepto,
      DESCRIPCION_TP: @variacion.descripcion_tp,
      DESCRIPCION_CO: @variacion.descripcion_co,
      IN_NOMINA: @variacion.in_nomina,
      INDICPAGO: @variacion.indic_pago,
      ESTATUS_CONCEPTO: @variacion.estatus_concepto,
      FE_NOMINA: @variacion.fe_nomina,
      FE_EFECTIVA: @variacion.fe_efectiva,
      STATUS_DEDUCCION: @variacion.estatus_deduccion,
      MO_CONCEP: @variacion.mo_concepto,
      MO_SALDO: @variacion.mo_saldo,
      STATUS_DEDUC: @variacion.status_deduc,
      TIPO_NOMINA: @variacion.tipo_nomina,
      TIPO_NOMINA_ESPECIFICA: @variacion.tipo_nomina_especifica,
      ANO: @variacion.ano,
      MES: @variacion.mes,
      INDICE_CONCEPTO: @variacion.indice_concepto
    )

    # 5. Guardado seguro con transacciones de Base de Datos
    ActiveRecord::Base.transaction do
      if @historico_pago.save && @variacion.save
        redirect_to variacion_path(@trab), notice: 'Variación registrada e historial de pago creado con éxito.'
      else
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid
    render :new
  end

  def historico_variaciones
    datos = JSON.parse(params[:trabajador])
    @hist = Variacion.where(
      ce_trabajador: datos['ce_trabajador'],
      co_ubicacion: datos['co_ubicacion'],
      tipopersonal: datos['tipopersonal']
    )
  end

  def destroy
    @elemento = Variacion.find(params[:id])
    @elemento.destroy
    redirect_to historico_variacions_path(trabajador: @elemento.to_json),
                notice: 'El elemento fue eliminado exitosamente.'
  end

  private

  def ubicar_cargo(id)
    Admon.find(id)
  end

  def estatus(trabajador)
    trabajador.estatus.eql?('P') and 'P' or trabajador.tp
  end

  def variacion_params_completos
    params.require(:variacion).permit(
      :ce_trabajador, :co_ubicacion, :tipopersonal, :co_concepto, :accion,
      :id_trabajador, :descripcion_tp, :ce_beneficiario, :descripcion_co,
      :in_nomina, :indic_pago, :estatus_concepto, :fe_nomina, :fe_efectiva,
      :estatus_deduccion, :mo_concepto, :mo_saldo, :status_deduc,
      :tipo_nomina, :tipo_nomina_especifica, :ano, :mes, :indice_concepto
    )
  end
end
