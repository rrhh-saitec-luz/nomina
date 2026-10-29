# Frozen_string_literal: true

# Trabajo en segundo plano
class CreacionPrenominaJob < ApplicationJob
  queue_as :default
  def perform(filtros)
    cont = Contador.find(1)
    begin
      HistoricoPago.generar_prenomina_en_segundo_plano(filtros)
      cont.update!(valor: 1)
      Turbo::StreamsChannel.broadcast_replace_to(
        'nomina_channel',
        target: 'contenido',
        template: 'admins/generar_nomina',
        layout: false,
        assigns: { contador: cont }
      )
    rescue StandardError => e
      cont.update!(valor: 0)
      HistoricoPago.delete_all
      Rails.logger.error "❌ FALLÓ Creación de Prenómina: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
