# Frozen_string_literal: true

# Clase para manejar información del trabajador
class TabTrabajadorsController < ApplicationController
  include Constantes

  def index
    @trabajadores = TabTrabajador.all
    @search_term = params[:q]
    @desc_estatus = DESCRIPCION_DE_ESTADOS
    @sidial = search_check(@search_term)
  end

  def new
    @nuevo = TabTrabajador.new
  end

  def show
    @trabajador = Admon.find(params[:id])
    @antiguedad = calculo_de_antiguedad(@trabajador)
    @turno = HORARIOS
    @fechas_estatus_cargo = fechas_gral_cargo(@trabajador)
    @fechas_estatus_adm = fechas_adm_cargo(@trabajador)
    @datos_cargo = datos_cargo_trabajador(@trabajador)
    @datos_trabajador = datos_personales(@trabajador)
    @datos_ingreso = ingreso_trabajador(@trabajador)
  end

  def create
    @nuevo = TabTrabajador.new(nuevo_ingreso_params)

    if @nuevo.save
      redirect_to tab_trabajadors_index_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def editi; end

  def update; end

  def destroy; end

  private

  def nuevo_ingreso_params
    params.permit(:cedula, :nombre1, :nombre2, :apellido1, :apellido2, :fecha_de_nac)
  end

  def search_check(search_term)
    return nil unless search_term.present?

    Admon.where('ce_trabajador::text ILIKE ?', "%#{search_term}%")
         .page(params[:page]).per(10)
  end
end
