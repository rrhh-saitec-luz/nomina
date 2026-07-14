# Frozen_string_literal: true

# Modelo Variacion
class Variacion < ApplicationRecord
  attr_accessor :descripcion_tp, :ce_beneficiario, :descripcion_co,
                :in_nomina, :indic_pago, :estatus_concepto, :fe_nomina,
                :fe_efectiva, :estatus_deduccion, :mo_concepto, :mo_saldo,
                :status_deduc, :tipo_nomina, :tipo_nomina_especifica, :ano, :mes,
                :indice_concepto, :id_trabajador

  validates :accion, presence: true

  validate :validar_accion_disponible

  private

  def validar_accion_disponible
    if %w[sustituir sumar restar].include?(accion)
      errors.add(:accion, 'temporalmente no permitida.')
    end
  end
end
