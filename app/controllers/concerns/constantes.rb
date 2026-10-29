# Frozen_string_literal: true

# Modulo para almacenar valores constantes o constantes creadas dinamicamente
module Constantes
  extend ActiveSupport::Concern

  DESCRIPCION_DE_ESTADOS = { 'A' => 'ACTIVO',
                             'F' => 'FALLECIDO',
                             'S' => 'SUSPENDIDO',
                             'R' => 'RETIRADO',
                             'P' => 'PENSIONADO',
                             'T' => 'PENSIONADO',
                             'C' => 'CONTRATADO' }.freeze

  DESCRIPCION_PRINCIPAL = { 'S' => 'SI', 'N' => 'NO' }.freeze

  HORARIOS = { 1 => 'Diurno', 3 => 'Mixto' }.freeze
end
