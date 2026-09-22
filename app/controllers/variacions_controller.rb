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
    @variacion.usuario = current_user&.nombre
    @variacion.status  = false

    transaccion(@trab, @variacion)
    render_new_with_errors unless @variacion.valid?
  rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid
    render _new_with_errors
  end

  def historico_variaciones
    @trabajador = Admon.find_by(
      ce_trabajador: params[:cedula], co_ubicacion: params[:codigo],
      tipopersonal: params[:tipo]
    )
    @presenter = TrabajadorPresenter.new(@trabajador)
    @datos = HistoricoPago.where(
      CE_TRABAJADOR: params[:cedula],
      CO_UBICACION: params[:codigo],
      TIPOPERSONAL: params[:tipo]
    )
  end

  def destroy
    @elemento = Variacion.find(params[:id])
    @elemento.destroy
    redirect_to historico_variacions_path(trabajador: @elemento.to_json),
                notice: 'El elemento fue eliminado exitosamente.'
  end

  private

  def estatus(trabajador)
    trabajador.estatus.eql?('P') and 'P' or trabajador.tp
  end

  def ejecutar_creacion!
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

    raise ActiveRecord::Rollback unless @historico_pago.save && @variacion.save
  end

  def ejecutar_eliminacion!
    variacion_previa = Variacion.find_by(
      ce_trabajador: @variacion.ce_trabajador,
      co_ubicacion: @variacion.co_ubicacion, tipopersonal: @variacion.tipopersonal,
      co_concepto: @variacion.co_concepto, status: false
    )

    @variacion.accion = variacion_previa.present? ? 'eliminar_abierto' : 'eliminar'
    @historico_pago = HistoricoPago.find_by(
      CE_TRABAJADOR: @variacion.ce_trabajador,
      CO_UBICACION: @variacion.co_ubicacion, TIPOPERSONAL: @variacion.tipopersonal,
      CO_CONCEPTO: @variacion.co_concepto
    )
    @historico_pago.destroy if @historico_pago
    raise ActiveRecord::Rollback unless @variacion.save
  end

  def transaccion(trabajador, variacion)
    ActiveRecord::Base.transaction do
      if variacion.accion == 'eliminar'
        ejecutar_eliminacion!
      else
        ejecutar_creacion!
      end

      redirect_to variacion_path(trabajador), notice: mensaje_exito
    end
  end

  def mensaje_exito
    if @variacion.accion == 'eliminar_abierto'
      'Concepto removido de la nómina actual.'
    elsif @variacion.accion == 'eliminar'
      'Concepto eliminado del historial de pagos.'
    else
      'Variación registrada e historial de pago creado con éxito.'
    end
  end

  def render_new_with_errors
    @con = Listado.all
    @tipo_nomina = NominaTipo.all
    @estatus = estatus(@trab)
    render :new and return
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
