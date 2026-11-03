# Frozen_string_literal: true

# Trabajo en segundo plano para el calculo de las antiguedades
class CalcularAntiguedadesJob < ApplicationJob
  queue_as :default

  FACTOR_DE_ANTIGUEDAD = 0.02
  IDXS      = { a: 'A' }.freeze
  INDP      = 'M'
  ESTATUS   = '0'
  DEDUCCION = 0
  TIPO      = 1

  def perform(f_nomina_str, idx_key_str)
    f_nomina = f_nomina_str.to_date
    idx = IDXS[idx_key_str.to_sym] || idx_key_str
    personas = activos_sin_jubilados_o_pensionados
    fecha_limite = f_nomina - 1.year
    personas_aptas = personas.where('fe_ingreso <= ?', fecha_limite)
    total = personas_aptas.count
    if total.zero?
      finalizar_proceso(f_nomina)
      return
    end
    procesar_personal_pa(personas_aptas, f_nomina, idx, total)
  end

  private

  def procesar_personal_pa(personas_aptas, f_nomina, idx, total)
    procesados = 0
    ahora = Time.current

    personas_aptas.in_batches(of: 100) do |batch|
      datos = batch.filter_map { |persona| preparar_registro_historico(persona, f_nomina, idx, ahora) }
      HistoricoPago.insert_all(datos) if datos.any?
      procesados += batch.size
      porcentaje = ((procesados.to_f / total) * 100).round
      barra_progreso(porcentaje, procesados, total)
    end

    finalizar_proceso(f_nomina)
  end

  def preparar_registro_historico(persona, f_nomina, idx, ahora)
    f_ingreso = persona.fe_ingreso.beginning_of_month
    servicio = tds(f_nomina, f_ingreso)
    monto = sda(persona.ce_trabajador, persona.co_ubicacion, persona.tipopersonal, idx, servicio)
    return nil if monto.zero?

    tipo = persona.tp
    concepto = codigo_concepto(persona.tp)
    persona.slice(:ce_trabajador, :co_ubicacion, :tipopersonal, :descripcion_tp)
           .merge(atributos_calculados(concepto, f_nomina, idx, servicio, monto, ahora, tipo))
  end

  def codigo_concepto(persona_tp)
    if persona_tp.eql?(1)
      ['A223', 'PRIMA POR ANTIGUEDAD DOCENTE']
    elsif persona_tp.eql?(2)
      ['A029', 'PRIMA POR ANTIGUEDAD ADMINISTRATIVO']
    else
      ['A436', 'PRIMA POR ANTIGUEDAD OBRERO']
    end
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

  def tds(nomina, ingreso)
    tiempo = nomina.year - ingreso.year
    tiempo -= 1 if nomina.month < ingreso.month || (nomina.month == ingreso.month && nomina.day < ingreso.day)
    tiempo
  end

  def sda(cedula, ubicacion, tipo, idx, servicio)

    asignaciones = HistoricoPago.where(CE_TRABAJADOR: cedula,
                                       CO_UBICACION: ubicacion,
                                       TIPOPERSONAL: tipo,
                                       INDICE_CONCEPTO: idx)
                                .map(&:MO_CONCEP).sum
    (asignaciones * FACTOR_DE_ANTIGUEDAD * servicio).round(2)
  end

  def barra_progreso(porcentaje, procesados, total)
    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'progreso_nomina',
      partial: 'admins/parciales/barra_progreso',
      locals: { porcentaje: porcentaje, procesados: procesados, total: total }
    )
  end

  def finalizar_proceso(f_nomina)
    contador = Contador.find_by(nombre: 'depurar') || Contador.first
    contador&.update(valor: 6)

    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'contenido',
      template: 'admins/antiguedades',
      layout: false,
      locals: { cont: 6, fecha: f_nomina }
    )
  end

  def activos_sin_jubilados_o_pensionados
    Admon.where(edo_cargo: %w[A])
         .where.not(tipopersonal: '110205')
         .where(" \"tipopersonal\" NOT LIKE '___8%' AND \"tipopersonal\" NOT LIKE '___9%' ")
  end
end
