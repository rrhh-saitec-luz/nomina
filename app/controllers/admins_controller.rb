# Frozen_string_literal: true

require 'activerecord-import'
# Todas las opciones de administrador
class AdminsController < ApplicationController
  include Constantes
  def index; end

  def generar_nomina
    contador = Contador.where(nombre: 'depurar').map(&:valor).first
    @nomina = NominaTipo.all
    @meses = MESES
    @years = concepto_pluck(:ANO)
    if contador.eql?(0)
      render partial: 'admins/parciales/generar_nomina'
    else
      render partial: 'admins/parciales/eliminar_prenomina'
    end
  end

  def prenomina
    registros_filtrados = prenomina_params
    @nomina = NominaTipo.all
    @meses = MESES
    @years = concepto_pluck(:ANO)
    procesar_registros(registros_filtrados)
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

  def depurar
    render partial: 'admins/parciales/depurar'
  end

  def antiguedades
    extract = 'EXTRACT(MONTH FROM fe_ingreso) = ?'
    @cumplir_ant = Admon.where(extract, 11).where(estatus: %w[A])
    render partial: 'admins/parciales/antiguedades'
  end

  def eliminar_inactivos
    ti = inactivos
    ca = cargos_en_nomina
    borrar_inactivos(ti, ca)
  end

  def actualizar_activos
    ta = activos
    ca = cargos_en_nomina
    actualizar(ta, ca)
  end

  def destruir_prenomina
    HistoricoPago.delete_all
    contador = Contador.where(nombre: 'depurar')
    reiniciar_contador(contador)
    generar_nomina
  end

  private

  def activos
    Admon.where(edo_cargo: %w[A P])
         .where.not(tipopersonal: '110205')
         .map { |t| [t.ce_trabajador, t.co_ubicacion.strip, t.tipopersonal.strip] }
  end

  def actualizar(activos, cargos)
  end

  def inactivos
    Admon.where.not(edo_cargo: %w[A P])
         .map { |t| [t.ce_trabajador, t.co_ubicacion.strip, t.tipopersonal.strip] }
  end

  def cargos_en_nomina
    HistoricoPago.select(:CE_TRABAJADOR, :CO_UBICACION, :TIPOPERSONAL)
                 .map { |c| [c.CE_TRABAJADOR, c.CO_UBICACION.strip, c.TIPOPERSONAL.strip] }.uniq
  end

  def borrar_inactivos(inactivos, cargos)
    borrar = inactivos.select { |c| c if cargos.include?(c) }
    borrar.map { |r| HistoricoPago.where(CE_TRABAJADOR: r[0], CO_UBICACION: r[1], TIPOPERSONAL: r[2]).delete_all }
    render partial: 'admins/parciales/depurar'
  end

  def procesar_registros(registros_filtrados)
    if registros_filtrados.empty?
      lotes_vacios
    else
      lotes(registros_filtrados)
    end
  end

  def lotes_vacios
    flash[:alert] = 'Busqueda sin resultados.'
    generar_nomina
  end

  def lotes(lote)
    lote.find_in_batches(batch_size: 1000) do |batch|
      nuevos_registros = batch.map do |registro|
        HistoricoPago.new(registro.attributes)
      end
      HistoricoPago.import nuevos_registros, validate: false
    end
    contador_nombre = Contador.where(nombre: 'depurar')
    sumar_contador(contador_nombre)
    generar_nomina
  end

  def sumar_contador(contador)
    nuevo_valor = contador.map { |val| val.valor + 1 }
    contador.update(valor: nuevo_valor.first)
  end

  def reiniciar_contador(contador)
    contador.update(valor: 0)
  end

  def concepto_pluck(campo)
    Concepto.all.select(campo).distinct.pluck(campo)
  end

  def prenomina_params
    Concepto.where(ANO: params[:year],
                   MES: params[:month],
                   TIPO_NOMINA: params[:tpn],
                   TIPO_NOMINA_ESPECIFICA: params[:tpns]).where.not(CO_CONCEPTO: %w[X500 A029 A223 A436])
  end
end
