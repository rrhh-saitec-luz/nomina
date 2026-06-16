# Frozen_string_literal: true

# Tabajo en segundo plano para calcular anticipo de quincena
class CalcularAnticiposJob < ApplicationJob
  queue_as :default

  def perform
    cont = Contador.find(1)
    begin
      # Seteamos el contador en un estado inicial (ej. 10 para "Procesando Anticipos")
      cont.update!(valor: 10)

      # Invocamos la lógica pesada en el modelo HistoricoPago
      HistoricoPago.generar_anticipos_x500_segundo_plano

      # Al finalizar con éxito, actualizamos el contador a un estado completado (ej. 11)
      cont.update!(valor: 11)
    rescue => e
      # Si falla, puedes poner un código de error (ej. 0 o 12)
      cont.update!(valor: 6)
      Rails.logger.error "FALLÓ Cálculo de Anticipos Quincenales X500: #{e.message}"
    end
  end
end

