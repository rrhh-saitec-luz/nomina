# Frozen_string_literal: true

require 'activerecord-import'
# Todas las opciones de administrador
class AdminsController < ApplicationController
  def index; end

  def generar_nomina
    render partial: 'admins/parciales/generar_nomina'
  end

  def prenomina
    registros_filtrados = Concepto.where(ANO: params[:year],
                                         MES: params[:month],
                                         TIPO_NOMINA: params[:tpn],
                                         TIPO_NOMINA_ESPACIFICA: params[:tpns])
    registros_filtrados.find_in_batches(batch_size: 1000) do |batch|
      nuevos_registros = batch.map do |registro|
        HistoricoPago.new(registro.attributes)
      end
      HistoricoPago.import nuevos_registros, validate: false
    end
    flash[:notice] = 'Proceso finalizado correctamente.'
    redirect_to admins_path
  end

  def modificar_prenomina
    @prenomina = HistoricoPago.all
    @meses = Concepto.all.select(:MES).distinct.pluck(:MES)
    @years = Concepto.all.select(:ANO).distinct.pluck(:ANO)
    @nominas = NominaTipo.all.select(:tipo_nomina).distinct.pluck(:tipo_nomina)
    @especificas = NominaEspecifica.all.select(:tipo_nomina_especifica).distinct.pluck(:tipo_nomina_especifica)
    render partial: 'admins/parciales/modificar_prenomina'
  end
end
