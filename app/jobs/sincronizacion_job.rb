class SincronizacionJob < ApplicationJob
  queue_as :default

  def perform(tipo)
    cont = Contador.find(1)
    begin
      cont_exito = job_cases(tipo)
      HistoricoPago.barra_progreso_cargos_final(tipo)
      cont.update!(valor: cont_exito)
    rescue => e
      valor_rescate = rescue_value(tipo)
      cont.update(valor: valor_rescate)
      Rails.logger.error "FALLÓ Sincronización (#{tipo}): #{e.message}"
    end
  end

  def job_cases(tipo)
    case tipo
    when :unicos
      unicos(tipo)
    when :multiple
      multiples(tipo)
    when :inactivos
      depurar_inactivos(tipo)
    end
  end

  def unicos(tipo)
    HistoricoPago.sincronizar_cargos_unicos(tipo)
    3
  end

  def multiples(tipo)
    HistoricoPago.detectar_inconsistencias_multiples(tipo)
    4
  end

  def depurar_inactivos(tipo)
    HistoricoPago.depurar_trabajadores_inactivos(tipo)
    5
  end

  def rescue_value(tipo)
    case tipo
    when :unicos then 2
    when :multiple then 3
    when :inactivos then 4
    end
  end
end
