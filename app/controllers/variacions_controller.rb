# Frozen_string_literal: true

# Clase para manejar las variaciones
class VariacionsController < ApplicationController
  include Constantes
  def index; end

  def show
    @trab = ubicar_cargo(params[:id])
    @datos_cargo = datos_cargo_trabajador(@trab)
  end

  private

  def ubicar_cargo(id)
    Admon.find(id)
  end
end
