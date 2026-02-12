# Frozen_string_literal: true

require 'activerecord-import'
# Todas las opciones de administrador
class AdminsController < ApplicationController
  include Constantes
  include AdminConcerns
  def index; end

  def generar_nomina
    @nomina = NominaTipo.all
    @meses = MESES
    @years = concepto_pluck(:ANO)
    if contador_depurar.map(&:valor).first.eql?(0)
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
    cont_val = contador_depurar.map(&:valor).first
    if cont_val.eql?(1)
      render partial: 'admins/parciales/modificar_prenomina', locals: { meses: MESES }
    else
      render partial: 'admins/parciales/otro_proceso', locals: { meses: MESES, cont: cont_val }
    end
  end

  def destruir_prenomina
    HistoricoPago.delete_all
    Multiple.delete_all
    reiniciar_contador(contador_depurar)
    generar_nomina
  end

  # Metodo para renderizar vista de depurar nomina
  def depurar
    contador = contador_depurar.map(&:valor).first
    render partial: 'admins/parciales/depurar', locals: { cont: contador }
  end

  # Método para eliminar trabajadores inactivos en la nomina
  def eliminar_inactivos
    trabajador_inactivo = inactivos
    cargos_activos = cargos_en_nomina
    borrar_inactivos(trabajador_inactivo, cargos_activos)
  end

  # Métodos para actualizar trabajadores activos en la prenomina
  def actualizar_activos
    trabajador_activo = activos
    cargo_activo = cargos_en_nomina
    actualizar_cargos(trabajador_activo, cargo_activo)
    sumar_contador(contador_depurar)
    depurar
  end

  def verificar_cargos_multiples
    contador = contador_depurar.map(&:valor).first
    multiples = Multiple.all.map(&:ce_trabajador).uniq
    nomina_actual = Admon.where(ce_trabajador: [multiples])
                         .pluck(:ce_trabajador, :nombres, :co_ubicacion, :tipopersonal)
    @cargos_trabajador = colectar_cargos(nomina_actual)
    render partial: 'admins/parciales/multiples',
           locals: { cont: contador, mul: multiples }
  end

  def antiguedades
    extract = 'EXTRACT(MONTH FROM fe_ingreso) = ?'
    @cumplir_ant = Admon.where(extract, 11).where(estatus: %w[A])
    render partial: 'admins/parciales/antiguedades'
  end

  private

  def actualizar_cargos(trab_act, cargos_act)
    actualizar = trab_act.select { |c| c unless cargos_act.include?(c) }.uniq
    candidatos_actualizar = actualizar.map(&:first).uniq
    verificar_cargos_activos = verif_cargos(candidatos_actualizar)
    car_mul_car(verificar_cargos_activos)
  end

  def verif_cargos(candidatos_actualizar)
    Admon.where(ce_trabajador: candidatos_actualizar, edo_cargo: %w[A P])
         .where.not(tipopersonal: '110205').map(&:ce_trabajador)
  end

  def car_mul_car(vca)
    trab_cargo_multiple = []
    trab_cargo = []
    vca.each do |t|
      trab_cargo.include?(t) and trab_cargo_multiple << t or trab_cargo << t
    end
    crear_cargos_multiples(trab_cargo_multiple.uniq)
    actualizar_trabajador_cargo_unico(trab_cargo, trab_cargo_multiple.uniq)
  end

  def actualizar_trabajador_cargo_unico(trc, trcm)
    trcu = trc.select { |t| t unless trcm.include?(t) }
    actualiza_trcu(trcu)
  end

  def actualiza_trcu(trcu)
    trcu.each do |t|
      actualizables = Admon.where(ce_trabajador: t, edo_cargo: %w[A P])
                           .where.not(tipopersonal: '110205')
      actualizables.each do |worker|
        HistoricoPago.where(CE_TRABAJADOR: worker.ce_trabajador)
                     .update(CO_UBICACION: worker.co_ubicacion,
                             TIPOPERSONAL: worker.tipopersonal,
                             DESCRIPCION_TP: worker.descripcion_tp)
      end
    end
  end

  def borrar_inactivos(inactivos, cargos)
    borrar = inactivos.select { |c| c if cargos.include?(c) }
    borrar.map { |r| HistoricoPago.where(CE_TRABAJADOR: r[0], CO_UBICACION: r[1], TIPOPERSONAL: r[2]).delete_all }
    sumar_contador(contador_depurar)
    depurar
  end

  # metodos para procesar o crear la prenomina

  def procesar_registros(registros_filtrados)
    if registros_filtrados.empty?
      flash[:alert] = 'Busqueda sin resultados.'
      generar_nomina
    else
      lotes(registros_filtrados)
    end
  end

  def lotes(lote)
    lote.find_in_batches(batch_size: 1000) do |batch|
      nuevos_registros = batch.map do |registro|
        HistoricoPago.new(registro.attributes)
      end
      HistoricoPago.import nuevos_registros, validate: false
    end
    sumar_contador(contador_depurar)
    generar_nomina
  end
end
