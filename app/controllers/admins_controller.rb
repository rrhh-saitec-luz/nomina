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

  def sincronizar
    tipo = params[:tipo] == 'multiple' ? :multiple : :unicos
    SincronizacionJob.perform_later(tipo)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("contenedor_boton_#{tipo}",
                               partial: 'admins/parciales/boton_deshabilitado',
                               locals: { tipo: tipo }),

          turbo_stream.replace("progreso_cargos_#{tipo}",
                               partial: 'admins/parciales/barra_progreso_cargos',
                               locals: { porcentaje: 0, procesados: 0, total: 100, tipo: tipo })
        ]
      end
      format.html { redirect_to admins_path, notice: 'Sincronización de cargos #{unicos} iniciada...' }
    end
  end

  # Metodo para renderizar vista de depurar nomina
  def depurar
    contador = contador_depurar.map(&:valor).first
    render partial: 'admins/parciales/depurar', locals: { cont: contador }
  end

  # Método para eliminar trabajadores inactivos en la nomina
    def depurar_inactivos
  total_eliminados = 0

  # Ajusta los nombres de las tablas y campos según tu modelo real
  # Reutilizamos la lógica de lotes para no saturar la memoria
  Admon.where.not(edo_cargo: ['A', 'P']).find_in_batches(batch_size: 500) do |batch|
    # Extraemos las tripletas del lote actual de Admon
    tripletas = batch.map { |a| [a.ce_trabajador, a.co_ubicacion, a.tipopersonal] }

    # Buscamos y eliminamos los registros correspondientes en HistoricoPago
    # Nota: Si usas Rails 6 o superior, puedes usar delete_by
    eliminados_en_lote = HistoricoPago.where(
      [:CE_TRABAJADOR, :CO_UBICACION, :TIPOPERSONAL] => tripletas
    ).delete_all

    total_eliminados += eliminados_en_lote
  end

  respond_to do |format|
    format.turbo_stream {
      render turbo_stream: [
        turbo_stream.replace("modulo_depuracion", partial: "admins/modulo_depuracion_completado")
      ]
    }
    format.html { redirect_to admins_path, notice: "Depuración exitosa: Se eliminaron #{total_eliminados} registros." }
  end
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
    cedulas_con_error = SyncError.pluck(:ce_trabajador)
    @datos_locales  = HistoricoPago.where(ce_trabajador: cedulas_con_error)
                                   .select(:ce_trabajador, :co_ubicacion, :tipopersonal)
                                   .distinct
                                   .group_by(&:ce_trabajador)
    @datos_externos = Admon.where(ce_trabajador: cedulas_con_error, edo_cargo: %w[A P])
                           .where.not(tipopersonal: '110205')
                           .group_by(&:ce_trabajador)
    render partial: 'admins/parciales/multiples'
  end

  def editar_cargo_multiple
    @cedula = params[:cedula]
    @co_ubicacion_actual = params[:co_ubicacion_actual]
    @tipopersonal_actual = params[:tipopersonal_actual]
    @cargo_muestra = HistoricoPago.find_by(
      ce_trabajador: @cedula,
      co_ubicacion: @co_ubicacion_actual,
      tipopersonal: @tipopersonal_actual
    )

    if @cargo_muestra.nil?
      redirect_to depurar_admins_path, alert: 'No se encontraron registros locales para este cargo.'
    end
  end

  def actualizar_cargo_multiple
    @cedula = params[:cedula]
    @co_ubicacion_actual = params[:co_ubicacion_actual]
    @tipopersonal_actual = params[:tipopersonal_actual]

    # Capturamos el lote de todos los conceptos del trabajador en ese cargo específico
    @conceptos = HistoricoPago.where(
      ce_trabajador: @cedula,
      co_ubicacion: @co_ubicacion_actual,
      tipopersonal: @tipopersonal_actual
    )

    # Ejecutamos la actualización masiva de la llave compuesta
    if @conceptos.update_all(
         co_ubicacion: params[:nuevo_co_ubicacion],
         tipopersonal: params[:nuevo_tipopersonal]
       )
      respond_to do |format|
        # Redirección con estatus :see_other para que Turbo actualice el frame de la tabla
        format.html { redirect_to depurar_admins_path, status: :see_other, notice: 'Cargo y conceptos actualizados con éxito.' }
      end
    else
      flash.now[:alert] = 'No se pudieron actualizar los registros.'
      render :editar_cargo_multiple, status: :unprocessable_entity
    end
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
    fecha_limite = f_nomina - 1.year
    personas_aptas = personas.where('fe_ingreso <= ?', fecha_limite)
    total = personas_aptas.count
    procesar_personal_pa(personas_aptas, f_nomina, idx, total)
  end

  def procesar_personal_pa(personas, f_nomina, idx, total)
    procesados = 0
    ahora = Time.current
    personas.in_batches(of: 100) do |batch|
      datos = batch.filter_map { |p| preparar_registro_historico(p, f_nomina, idx, ahora) }
      HistoricoPago.insert_all(datos) if datos.any?
      procesados += batch.size
      porcentaje = ((procesados.to_f / total) * 100).round
      barra_progreso(porcentaje, procesados, total)
    end
    barra_progreso_mensaje_final
  end

  def preparar_registro_historico(persona, f_nomina, idx, ahora)
    f_ingreso = persona.fe_ingreso.beginning_of_month
    servicio = tds(f_nomina, f_ingreso)
    monto = sda(persona.ce_trabajador, persona.co_ubicacion,
                persona.tipopersonal, idx, servicio)
    return nil if monto.zero?

    tipo = persona.tp
    concepto = codigo_concepto(persona.tp)
    persona.slice(:ce_trabajador, :co_ubicacion, :tipopersonal, :descripcion_tp)
           .merge(atributos_calculados(concepto, f_nomina, idx, servicio, monto, ahora, tipo))
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
