# Frozen_string_literal: true

require 'activerecord-import'
# Todas las opciones de administrador
class AdminsController < ApplicationController
  def index; end

  def generar_nomina
    render partial: 'admins/parciales/generar_nomina'
  end

  def prenomina
    registros_filtrados = Concepto.where(ANO: params[:year], MES: params[:month])
    registros_filtrados.find_in_batches(batch_size: 1000) do |batch|
      nuevos_registros = batch.map do |registro|
        HistoricoPago.new(registro.attributes)
      end
      HistoricoPago.import nuevos_registros, validate: false
    end
    flash[:notice] = 'Proceso finalizado correctamente.'
    redirect_to admins_path
  end
end
