# Frozen_string_literal: true

# Trabajo que copiará la nueva nomina en la tabla que guardará las nominas de todos los tiempos
class CierreNominaJob < ApplicationJob
  queue_as :default

  def perform
    total_registros = HistoricoPago.count

    if total_registros.zero?
      comunicar_exito_final
      return
    end

    procesados = 0
    # Abrimos la transacción de seguridad inmutable
    ActiveRecord::Base.transaction do
      lote_conceptos = []

      HistoricoPago.find_each(batch_size: 5000) do |historico|
        # Extraemos los datos como un simple Hash (sin instanciar objetos completos)
        lote_conceptos << historico.attributes.except('id', 'created_at', 'updated_at')
        procesados += 1

        # Cada vez que juntamos 5,000 registros, los insertamos en un solo golpe de base de datos
        if lote_conceptos.size >= 5000 || procesados == total_registros
          Concepto.insert_all!(lote_conceptos) # 🌟 Inserta miles de filas en milisegundos
          lote_conceptos = [] # Vaciamos el lote para el siguiente bloque

          # Reportamos el avance a la barra delgada sin saturar
          porcentaje_actual = ((procesados.to_f / total_registros) * 100).to_i
          transmitir_progreso(porcentaje_actual, procesados, total_registros)
        end
      end
    end

    comunicar_exito_final
  rescue StandardError => e
    Rails.logger.error "❌ Error crítico en CierreNominaJob: #{e.message}"
    transmitir_error # <- Ahora sí llamará al método privado correctamente
  end

  private

  # Transmite el avance de la barra de progreso delgada (12px)
  def transmitir_progreso(porcentaje, procesados, total)
    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'progreso_cierre',
      partial: 'admins/parciales/barra_progreso_cierre',
      locals: { porcentaje: porcentaje, procesados: procesados, total: total }
    )
  end

  # Transmite el aviso de éxito final y remueve el botón falso de "Procesando"
  def comunicar_exito_final
    contador = Contador.first # O como lo invoques en tu controlador
    contador&.update(valor: 8)

    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'progreso_cierre',
      partial: 'admins/parciales/barra_progreso_cierre_final'
    )

    Turbo::StreamsChannel.broadcast_action_to(
      'nomina_channel',
      action: :remove,
      target: 'contenedor_boton_cierre'
    )
  end

  # CORRECCIÓN DE SINTAXIS: Aseguramos que el método exista para el bloque rescue
  def transmitir_error
    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'progreso_cierre',
      html: "
        <div class='alert bg-danger bg-opacity-10 border border-danger border-opacity-10 rounded-3 d-flex align-items-center gap-2 py-3 px-4 text-danger small fw-medium mt-3'>
          <i class='bi bi-shield-slash-fill fs-4'></i>
          <span>Ocurrió un error interno durante el cierre. No se modificó ningún registro por seguridad.</span>
        </div>
      "
    )
  end
end
