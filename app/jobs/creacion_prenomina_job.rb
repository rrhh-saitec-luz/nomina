# Frozen_string_literal: true

# Trabajo en segundo plano
class CreacionPrenominaJob < ApplicationJob
  queue_as :default

  def perform(filtros)
    cont = Contador.find(1)

    # 🌟 1. BLOQUEO ASÍNCRONO INMEDIATO: El Job congela el botón e inicializa la barra
    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'boton_prenomina_contenedor',
      partial: 'admins/parciales/generar_nomina_boton_procesando'
    )
    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'progreso_cargos_creacion',
      partial: 'admins/parciales/barra_progreso',
      locals: { porcentaje: 0, procesados: 0, total: 100 }
    )

    # 🚀 2. Invocamos la lógica pesada del modelo informando el avance real por bloque
    HistoricoPago.generar_prenomina_en_segundo_plano(filtros) do |porcentaje, procesados, total|
      Turbo::StreamsChannel.broadcast_replace_to(
        'nomina_channel',
        target: 'progreso_cargos_creacion',
        partial: 'admins/parciales/barra_progreso',
        locals: { porcentaje: porcentaje, procesados: procesados, total: total }
      )
    end

    # 🌟 3. FINALIZACIÓN CON ÉXITO: Avanzamos a Fase 1 y redibujamos la pantalla limpia
    cont.update!(valor: 1)
    cont.reload

    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'contenido_formulario_nomina',
      partial: 'admins/parciales/cuerpo_prenomina',
      locals: {
        "@contador": cont,
        fase_actual: 1,
        contador: cont,
        years: Concepto.pluck(:ANO).uniq,
        nomina: NominaTipo.all
      }
    )
  rescue StandardError => e
    cont.update!(valor: 0)
    HistoricoPago.delete_all
    Rails.logger.error "❌ FALLÓ Creación de Prenómina: #{e.message}"

    # Restablecemos la interfaz original en caso de catástrofe
    Turbo::StreamsChannel.broadcast_replace_to(
      'nomina_channel',
      target: 'contenido_formulario_nomina',
      partial: 'admins/parciales/cuerpo_prenomina',
      locals: {
        "@contador": cont,
        fase_actual: 0,
        contador: cont,
        years: Concepto.pluck(:ANO).uniq,
        nomina: NominaTipo.all
      }
    )
  end
end
