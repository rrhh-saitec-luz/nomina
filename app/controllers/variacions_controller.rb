# Frozen_string_literal: true

# Clase para manejar las variaciones
class VariacionsController < ApplicationController
  include Constantes
  def index; end

  def show
    @trab = ubicar_cargo(params[:id])
    @datos_cargo = datos_cargo_trabajador(@trab)
  end

  def new
    @trab = Admon.find(params[:id])
    @variacion = Variacion.new
    @con = Listado.all
    @tipo_nomina = NominaTipo.all
    @tipo_nomina_especifica = NominaEspecifica.all
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
    @variacion = Variacion.new(variacion_params)
    if @variacion.save
      redirect_to variacion_path(@trab), notice: 'Variación creada'
    else
      render new_variacion_path
    end
  end

  private

  def ubicar_cargo(id)
    Admon.find(id)
  end

  def estatus(trabajador)
    trabajador.estatus.eql?('P') and 'P' or trabajador.tp
  end

  def variacion_params
    params.require(:variacion).permit(
      :ce_trabajador, :co_ubicacion, :tipopersonal, :descripcion_tp,
      :ce_beneficiario, :co_concepto, :descripcion_co, :in_nomina,
      :indic_pago, :estatus_concepto, :fe_nomina, :fe_efectiva,
      :fe_efectiva_real, :estatus_deduccion, :mo_concepto,
      :mo_saldo, :status_deduc, :tipo_nomina, :tipo_nomina_especifica,
      :ano, :mes, :indice_concepto, :usuario, :status, :usuario, :accion
    )
  end
end
