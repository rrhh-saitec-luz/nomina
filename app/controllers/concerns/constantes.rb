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

  HORARIOS = { 1 => 'Diurno', 2 => 'Mixto' }.freeze

  MESES = [[1, 'Enero'],
           [2, 'Febrero'],
           [3, 'Marzo'],
           [4, 'Abril'],
           [5, 'Mayo'],
           [6, 'Junio'],
           [7, 'Julio'],
           [8, 'Agosto'],
           [9, 'Septiembre'],
           [10, 'Octubre'],
           [11, 'Noviembre'],
           [12, 'Diciembre']].freeze
end
