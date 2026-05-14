class SincronizacionJob < ApplicationJob
  queue_as :default

  def perform(tipo)
    cont = Contador.find(1)
    begin
      if tipo == :unicos
        HistoricoPago.sincronizar_cargos_unicos(tipo)
      else
        HistoricoPago.detectar_inconsistencias_multiples(tipo)
      end
      HistoricoPago.barra_progreso_cargos_final(tipo)
      tipo == :unicos ? cont.update!(valor: 3) : cont.update!(4)

    rescue => e
      cont.update(valor: 2)
      Rails.logger.error "FALLÓ Sincronización: #{e.message}"
    end
  end
end
