# Frozen_string_literal: true

require 'activerecord-import'
require 'date'

# Todas las opciones de administrador
class AdminsController < ApplicationController
  include Constantes
  include AdminConcerns
  include AdminComplementoConcerns
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
    @nomina_actual = buscar_nomina_actual(multiples)
    prenomina_actual = buscar_prenomina_actual(multiples)
    @cargos_trabajador = colectar_cargos(@nomina_actual)
    @cargos_prenomina = colectar_cargos_prenomina(prenomina_actual)
    render partial: 'admins/parciales/multiples', locals: { cont: contador }
  end

  def detalles
    @tipo = params[:tipo].to_i
    @nombre = Admon.where(ce_trabajador: params[:cedula]).first.nombres
    @detallado = if @tipo.eql?(1)
                   buscar_en_admon
                 else
                   buscar_en_historico
                 end
  end

  def editar_prenomina
    conceptos = buscar_en_historico_todos
    conceptos.update_all(CO_UBICACION: params[:nueva_ubicacion],
                         TIPOPERSONAL: params[:nuevo_tipo])
    multiples = Multiple.all.map(&:ce_trabajador).uniq
    prenomina_actual = buscar_prenomina_actual(multiples)
    @cargos_prenomina = colectar_cargos_prenomina(prenomina_actual)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to vcm_admins_path }
    end
  end

  def antiguedades
    @fa = FACTOR_DE_ANTIGUEDAD
    @contador = contador_depurar.map(&:valor).first
    render partial: 'admins/parciales/antiguedades'
  end

  def suma_de_asignaciones
    personas = activos_sin_jubilados_o_pensionados
    f_nomina = params[:fe_nomina].to_date.beginning_of_month
    procesar_asignaciones(personas, f_nomina)
  end

  private

  def procesar_asignaciones(personas, f_nomina)
    idx = IDXS[:a]
    procesar_personal_pa(personas, f_nomina, idx)
  end

  def procesar_personal_pa(personas, f_nomina, idx)
    total = personas.count
    procesados = 0
    personas.in_batches(of: 100) do |batch|
      datos = batch.map { |p| preparar_registro_historico(p, f_nomina, idx) }
      HistoricoPago.insert_all(datos)
      procesados += batch.size
      porcentaje = ((procesados.to_f / total) * 100).round
      barra_progreso(porcentaje, procesados, total)
    end
    barra_progreso_mensaje_final
  end

  def barra_progreso(porcentaje, procesados, total)
    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'progreso_nomina',
      partial: 'admins/parciales/barra_progreso',
      locals: { porcentaje:, procesados:, total: }
    )
  end

  def barra_progreso_mensaje_final
    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'progreso_nomina',
      partial: 'admins/parciales/barra_progreso_mensaje_final'
    )
  end

  def preparar_registro_historico(persona, f_nomina, idx)
    f_ingreso = persona.fe_ingreso.beginning_of_month
    ahora = Time.current
    tipo = persona.tp
    concepto = codigo_concepto(persona.tp)
    servicio = tds(f_nomina, f_ingreso)
    monto = sda(persona.ce_trabajador, persona.co_ubicacion,
                persona.tipopersonal, idx, servicio)
    persona.slice(:ce_trabajador, :co_ubicacion, :tipopersonal, :descripcion_tp)
           .merge(atributos_calculados(concepto, f_nomina, idx, servicio, monto,
                                       ahora, tipo))
  end

  # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
  def atributos_calculados(concepto, f_nomina, idx, servicio, monto, ahora, tipo)
    {
      ce_beneficiario: '',
      co_concepto: concepto.first,
      descripcion_co: concepto.last,
      in_nomina: tipo.to_s,
      indicpago: INDP,
      estatus_concepto: ESTATUS,
      fe_nomina: f_nomina,
      fe_efectiva: f_nomina,
      status_deduccion: DEDUCCION,
      mo_concep: monto,
      mo_saldo: servicio,
      status_deduc: '',
      tipo_nomina: TIPO,
      tipo_nomina_especifica: TIPO,
      ano: f_nomina.year,
      mes: f_nomina.month,
      indice_concepto: idx,
      created_at: ahora,
      updated_at: ahora
    }
  end
  # rubocop:enable Metrics/MethodLength, Metrics/ParameterLists

  def codigo_concepto(persona_tp)
    if persona_tp.eql?(1)
      ['A223', 'PRIMA POR ANTIGUEDAD DOCENTE']
    elsif persona_tp.eql?(2)
      ['A029', 'PRIMA POR ANTIGUEDAD ADMINISTRATIVO']
    else
      ['A436', 'PRIMA POR ANTIGUEDAD OBRERO']
    end
  end

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
