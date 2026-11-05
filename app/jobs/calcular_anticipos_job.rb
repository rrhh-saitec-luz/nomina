# Frozen_string_literal: true

# Trabajo en segundo plano para el calculo de anticipos
class CalcularAnticiposJob < ApplicationJob
  queue_as :default

  def perform
    contador = Contador.find(1)

    # 🚀 Ejecutamos el método del modelo y capturamos el progreso efímero
    HistoricoPago.generar_anticipos_x500_segundo_plano do |porcentaje, procesados, total|

      # 🌟 SOLO TRANSMITIMOS EL PORCENTAJE POR WEBSOCKET. No tocamos la base de datos aquí.
      Turbo::StreamsChannel.broadcast_replace_to(
        'nomina_channel',
        target: 'progreso_anticipos',
        partial: 'admins/parciales/barra_progreso_anticipos',
        locals: { porcentaje: porcentaje, procesados: procesados, total: total }
      )
    end

    # 🌟 UNA SOLA ESCRITURA AL FINALIZAR: Avanzamos el flujo global a Fase 7
    contador.update!(valor: 7)

    # Removemos el botón procesando
    Turbo::StreamsChannel.broadcast_action_to(
      'nomina_channel',
      action: :remove,
      target: 'contenedor_boton_anticipos'
    )

    # Renderizamos el parcial de éxito final
    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'progreso_anticipos',
      partial: 'admins/parciales/barra_progreso_anticipos_final'
    )

  rescue StandardError => e
    # En caso de error, nos aseguramos de dejar el sistema firmemente en Fase 6
    contador.update!(valor: 6)
    Rails.logger.error "❌ FALLÓ Cálculo de Anticipos Quincenales X500: #{e.message}"
  end
end


