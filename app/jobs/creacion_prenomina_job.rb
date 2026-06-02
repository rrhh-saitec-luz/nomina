# Frozen_string_literal: true

# Trabajo segundo plano para crear nomina
class CreacionPrenominaJob < ApplicationJob
  queue_as :default

  def perform(filtros)
    cont = Contador.find(1) # Tu registro de control único
    begin
      # Invocamos la lógica pesada en el modelo pasando los filtros
      HistoricoPago.generar_prenomina_en_segundo_plano(filtros)
      cont.update!(valor: 1)
    rescue => e
      cont.update!(valor: 0)
      Rails.logger.error "FALLÓ Creación de Prenómina: #{e.message}"
    end
  end
end
