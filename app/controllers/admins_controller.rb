# Frozen_string_literal: true

require 'activerecord-import'
# Todas las opciones de administrador
class AdminsController < ApplicationController
  include Constantes
  def index; end

  def generar_nomina
    @nomina = NominaTipo.all
    @meses = MESES
    @years = concepto_pluck(:ANO)
    flash[:notice] = ''
    flash[:alert] = ''
    render partial: 'admins/parciales/generar_nomina'
  end

  def prenomina
    registros_filtrados = prenomina_params
    @nomina = NominaTipo.all
    @meses = MESES
    @years = concepto_pluck(:ANO)
    procesar_registros(registros_filtrados, @meses, @years, @nomina)
  end

  def modificar_prenomina
    flash[:notice] = ''
    flash[:alert] = ''
    render partial: 'admins/parciales/modificar_prenomina', locals: { meses: MESES }
  end

  def actualizar_prenomina
    flash[:notice] = 'Proceso finalizado correctamente.'
    HistoricoPago.update_all(MES: params[:mes], ANO: params[:year], FE_NOMINA: params[:fecha])
    render partial: 'admins/parciales/modificar_prenomina',
           locals: { meses: MESES }
  end

  def retiros
    render partial: 'admins/parciales/retiros'
  end

  def retirar
    resultado = buscar_retirados(params[:fe_inicio], params[:fe_fin])
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          'retirados', partial: 'admins/parciales/retiros_busqueda', locals: { personas: resultado }
        )
      end
    end
  end

  private

  def buscar_retirados(fe_inicial, fe_final)
    inicio = Date.parse(fe_inicial)
    final = Date.parse(fe_final)
    Admon.where(fe_retiro: inicio..final)
  end

  def procesar_registros(registros_filtrados, mes, year, nomina)
    if registros_filtrados.empty?
      lotes_vacios(mes, year, nomina)
    else
      lotes(registros_filtrados, mes, year, nomina)
    end
  end

  def lotes_vacios(l_mes, l_year, l_nomina)
    flash[:alert] = 'Busqueda sin resultados.'
    render partial: 'admins/parciales/generar_nomina',
           locals: { meses: l_mes, years: l_year, nomina: l_nomina }
  end

  def lotes(lote, l_mes, l_year, l_nomina)
    lote.find_in_batches(batch_size: 1000) do |batch|
      nuevos_registros = batch.map do |registro|
        HistoricoPago.new(registro.attributes)
      end
      HistoricoPago.import nuevos_registros, validate: false
    end
    flash[:notice] = 'Proceso finalizado correctamente.'
    render partial: 'admins/parciales/generar_nomina',
           locals: { meses: l_mes, years: l_year, nomina: l_nomina }
  end

  def concepto_pluck(campo)
    Concepto.all.select(campo).distinct.pluck(campo)
  end

  def prenomina_params
    Concepto.where(ANO: params[:year],
                   MES: params[:month],
                   TIPO_NOMINA: params[:tpn],
                   TIPO_NOMINA_ESPECIFICA: params[:tpns])
  end
end
