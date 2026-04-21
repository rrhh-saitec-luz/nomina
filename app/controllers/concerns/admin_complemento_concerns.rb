# Frozen_string_literal: true

# Modulo para ayudar el controlador Admin y almacenar otros métodos secundarios
module AdminComplementoConcerns
  extend ActiveSupport::Concern

  # Métodos para calcular las antiguedades

  FACTOR_DE_ANTIGUEDAD = 0.02
  IDXS = { a: 'A' }.freeze
  INDP = 'M'
  ESTATUS = '0'
  DEDUCCION = 0
  TIPO = 1

  def activos_sin_jubilados_o_pensionados
    Admon.where(edo_cargo: %w[A])
         .where.not(tipopersonal: '110205')
         .where(" \"tipopersonal\" NOT LIKE '___8%' AND \"tipopersonal\" NOT LIKE '___9%' ")
  end

  # Tiempo De Servicio (TDS)
  def tds(nomina, ingreso)
    tiempo = nomina.year - ingreso.year
    tiempo -= 1 if nomina.month < ingreso.month || (nomina.month == ingreso.month && nomina.day < ingreso.day)
    tiempo
  end

  # Suma De Asignaciones (SDA)
  def sda(cedula, ubicacion, tipo, idx, servicio)
    asignaciones = HistoricoPago.where(CE_TRABAJADOR: cedula,
                                       CO_UBICACION: ubicacion,
                                       TIPOPERSONAL: tipo,
                                       INDICE_CONCEPTO: idx)
                                .map(&:MO_CONCEP).sum
    (asignaciones * FACTOR_DE_ANTIGUEDAD * servicio).round(2)
  end
end
