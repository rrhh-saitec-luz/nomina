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
    @variacion = Variacion.new
  end

  def create
    @form = Variacion.new(variacion_params)
    if @form.save
      redirect_to root_path, notice: 'Variación creada'
    else
      render new_variacion_path
    end
  end

  private

  def ubicar_cargo(id)
    Admon.find(id)
  end

  def variacion_params
    params.require(:variacion).permit(
      :ce_trabajador, :co_ubicacion, :tipopersonal, :descripcion_tp,
      :ce_beneficiario, :co_concepto, :descripcion_co, :in_nomina,
      :inicpago, :estatus_concepto, :fe_nomina, :fe_efectiva,
      :fe_efectiva_real, :estatus_deduccion, :mo_concepto,
      :mo_saldo, :status_deduc, :tipo_nomina, :tipo_nomina_especifica,
      :ano, :mes, :indice_concepto, :usuario, :status, :usuario, :accion
    )
  end
end
