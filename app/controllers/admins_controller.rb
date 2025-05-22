# Frozen_string_literal: true

require 'activerecord-import'
# Todas las opciones de administrador
class AdminsController < ApplicationController
  def index; end

  def generar_nomina
    render partial: 'admins/parciales/generar_nomina'
  end

  def prenomina
    Concepto.find_in_batches(batch_size: 1000) do |batch|
      nuevos_registros = []

      batch.each do |registro|
        nuevo_registro = registro.dup
        nuevos_registros << nuevo_registro if registro.ANO == params[:year] && registro.MES == params[:mes]
      end
      Concepto.import nuevos_registros, validate: false
    end
  end
end
