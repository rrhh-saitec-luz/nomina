# Frozen_string_literal: true

# Todas las opciones de administrador
class AdminsController < ApplicationController
  def index; end

  def generar_nomina
    
    render partial: 'admins/parciales/generar_nomina'
  end
end
