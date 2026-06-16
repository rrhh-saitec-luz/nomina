  def self.generar_anticipos_x500_segundo_plano
    cont = Contador.find(1)

    # 1. Obtener automáticamente los metadatos del lote actual
    ultimo_registro = self.order(created_at: :desc).first
    return if ultimo_registro.nil?

    año_proceso  = ultimo_registro.ANO
    mes_proceso  = ultimo_registro.MES
    fecha_nomina = ultimo_registro.FE_NOMINA

    # 2. Agrupación y suma compatible con PostgreSQL
    totales_por_cargo = self
      .where(ANO: año_proceso, MES: mes_proceso)
      .where.not(IN_NOMINA: 'P')
      .where(INDICE_CONCEPTO: ['A', 'X', 'Y'])
      .group(:CE_TRABAJADOR, :CO_UBICACION, :TIPOPERSONAL, :DESCRIPCION_TP, :TIPO_NOMINA, :TIPO_NOMINA_ESPECIFICA, :CE_BENEFICIARIO, :IN_NOMINA)
      .select(
        :CE_TRABAJADOR, :CO_UBICACION, :TIPOPERSONAL, :DESCRIPCION_TP, :TIPO_NOMINA, :TIPO_NOMINA_ESPECIFICA, :CE_BENEFICIARIO, :IN_NOMINA,
        'SUM(CASE WHEN "INDICE_CONCEPTO" = \'A\' THEN "MO_CONCEP" ELSE 0 END) AS total_asignaciones',
        'SUM(CASE WHEN "INDICE_CONCEPTO" IN (\'X\', \'Y\') THEN "MO_CONCEP" ELSE 0 END) AS total_deducciones'
      ).to_a

    total_registros = totales_por_cargo.size
    return if total_registros.zero?

    # 3. Iteración y creación de registros
    self.transaction do
      totales_por_cargo.each_with_index do |cargo, index|
        total_a  = cargo.total_asignaciones.to_f
        total_xy = cargo.total_deducciones.to_f
        
        adelanto_quincena = (total_a - total_xy) / 2.0

        if adelanto_quincena > 0
          self.create!(
            CE_TRABAJADOR:          cargo.CE_TRABAJADOR,
            CO_UBICACION:           cargo.CO_UBICACION,
            TIPOPERSONAL:           cargo.TIPOPERSONAL,
            DESCRIPCION_TP:         cargo.DESCRIPCION_TP,
            CE_BENEFICIARIO:        cargo.CE_BENEFICIARIO,
            CO_CONCEPTO:            "X500",
            DESCRIPCION_CO:         "ANTICIPO 1RA QUINCENA LUZ",
            IN_NOMINA:              cargo.IN_NOMINA,
            INDICPAGO:              "M",
            ESTATUS_CONCEPTO:       "A",
            FE_NOMINA:              fecha_nomina,
            FE_EFECTIVA:            fecha_nomina,
            STATUS_DEDUCCION:       0.0,
            MO_CONCEP:              adelanto_quincena,
            MO_SALDO:               0.0,
            STATUS_DEDUC:           nil,
            TIPO_NOMINA:            cargo.TIPO_NOMINA,
            TIPO_NOMINA_ESPECIFICA: cargo.TIPO_NOMINA_ESPECIFICA,
            ANO:                    año_proceso,
            MES:                    mes_proceso,
            INDICE_CONCEPTO:        "X"
          )
        end

        # Emitir progreso por WebSocket a través de Turbo Streams
        procesados = index + 1
        if (procesados % 20).zero? || (procesados == total_registros)
          porcentaje = ((procesados.to_f / total_registros) * 100).round
          
          # Actualizar base de datos de control
          cont.update_column(:valor, porcentaje)

          # Transmitir al navegador en tiempo real (Bootstrap nativo)
          Turbo::StreamsChannel.broadcast_replace_to(
            'nomina_channel',
            target: 'progreso_anticipos',
            partial: 'admins/parciales/barra_progreso_anticipos',
            locals: { porcentaje: porcentaje, procesados: procesados, total: total_registros }
          )
        end
      end
    end

    # Mensaje final de éxito al terminar las inserciones
    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'progreso_anticipos',
      partial: 'admins/parciales/barra_progreso_anticipos_final'
    )
  end

