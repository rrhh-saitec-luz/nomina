# Frozen_string_literal: true

# Calculo de Anticipos
module CalculoAnticipos
  extend ActiveSupport::Concern
  class_methods do
    def generar_anticipos_x500_segundo_plano
      ultimo_registro = order(created_at: :desc).first

      return if ultimo_registro.nil?

      ano_proceso  = ultimo_registro.ANO
      mes_proceso  = ultimo_registro.MES
      fecha_nomina = ultimo_registro.FE_NOMINA
      totales_por_cargo = where(ANO: ano_proceso, MES: mes_proceso)
                          .where.not(IN_NOMINA: 'P')
                          .where(INDICE_CONCEPTO: %w[A X Y])
                          .group(:CE_TRABAJADOR,
                                 :CO_UBICACION,
                                 :TIPOPERSONAL,
                                 :DESCRIPCION_TP,
                                 :TIPO_NOMINA,
                                 :TIPO_NOMINA_ESPECIFICA,
                                 :CE_BENEFICIARIO, :IN_NOMINA)
                          .select(
                            :CE_TRABAJADOR,
                            :CO_UBICACION,
                            :TIPOPERSONAL,
                            :DESCRIPCION_TP,
                            :TIPO_NOMINA,
                            :TIPO_NOMINA_ESPECIFICA,
                            :CE_BENEFICIARIO,
                            :IN_NOMINA,
                            'SUM(CASE WHEN "INDICE_CONCEPTO" = \'A\' THEN "MO_CONCEP" ELSE 0 END) AS total_asignaciones',
                            'SUM(CASE WHEN "INDICE_CONCEPTO" IN (\'X\', \'Y\') THEN "MO_CONCEP" ELSE 0 END) AS total_deducciones'
                          ).to_a

      total_registros = totales_por_cargo.size

      return if total_registros.zero?

      transaction do
        totales_por_cargo.each_with_index do |cargo, index|
          total_a  = cargo.total_asignaciones.to_f
          total_xy = cargo.total_deducciones.to_f
          adelanto_quincena = (total_a - total_xy) / 2.0
          if adelanto_quincena.positive?
            create!(
              CE_TRABAJADOR: cargo.CE_TRABAJADOR,
              CO_UBICACION: cargo.CO_UBICACION,
              TIPOPERSONAL: cargo.TIPOPERSONAL,
              DESCRIPCION_TP: cargo.DESCRIPCION_TP,
              CE_BENEFICIARIO: cargo.CE_BENEFICIARIO,
              CO_CONCEPTO: 'X500',
              DESCRIPCION_CO: 'ANTICIPO 1RA QUINCENA LUZ',
              IN_NOMINA: cargo.IN_NOMINA,
              INDICPAGO: 'M',
              ESTATUS_CONCEPTO: 'A',
              FE_NOMINA: fecha_nomina,
              FE_EFECTIVA: fecha_nomina,
              STATUS_DEDUCCION: 0.0,
              MO_CONCEP: adelanto_quincena,
              MO_SALDO: 0.0,
              STATUS_DEDUC: nil,
              TIPO_NOMINA: cargo.TIPO_NOMINA,
              TIPO_NOMINA_ESPECIFICA: cargo.TIPO_NOMINA_ESPECIFICA,
              ANO: ano_proceso,
              MES: mes_proceso,
              INDICE_CONCEPTO: 'X'
            )
          end
          procesados = index + 1

          # 🌟 INTERSECCIÓN INTELIGENTE: Si el Job nos pasó un bloque, le reportamos el progreso
          if block_given? && ((procesados % 20).zero? || (procesados == total_registros))
            porcentaje = ((procesados.to_f / total_registros) * 100).round
            yield(porcentaje, procesados, total_registros)
          end
        end
      end
    end
  end
end
