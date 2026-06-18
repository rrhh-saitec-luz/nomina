#  frozen_string_literal: true

# app/presenters/trabajador_presenter.rb
class TrabajadorPresenter < SimpleDelegator
  # Esto te permite usar métodos como 'link_to' o helpers de rutas
  include ActionView::Helpers::UrlHelper
  include Constantes

  def initialize(trabajador)
    super(trabajador) # Esto delega los métodos directamente al modelo @trabajador
  end

  def datos_personales
    {
      'Nombre:' => nombres, # Ya no necesitas poner @trabajador.nombres, se hereda directamente
      'Cédula:' => ce_trabajador,
      'Estatus:' => DESCRIPCION_DE_ESTADOS[estatus]
    }
  end
end
