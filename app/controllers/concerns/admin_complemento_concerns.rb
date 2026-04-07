# Frozen_string_literal: true

# Modulo para ayudar el controlador Admin y almacenar otros métodos secundarios
module AdminComplementoConcerns
  extend ActiveSupport::Concern

  # Métodos para calcular las antiguedades

  FACTOR_DE_ANTIGUEDAD = 0.02

  def activos_sin_jubilados_o_pensionados
    Admon.where(edo_cargo: %w[A])
         .where.not(tipopersonal: '110205')
         .where(" \"tipopersonal\" NOT LIKE '___8%' AND \"tipopersonal\" NOT LIKE '___9%' ")
  end

  def calculo_de_tiempo_de_servicio(nomina, ingreso)
    tiempo = nomina.year - ingreso.year
    tiempo -= 1 if nomina.month < ingreso.month
    tiempo
  end

  def suma_de_asignaciones(cedula, ubicacion, tipo)
    HistoricoPago.where(CE_TRABAJADOR: cedula,
                        CO_UBICACION: ubicacion,
                        TIPOPERSONAL: tipo)
                 .map(&:MONTO_CONCEP).sum
  end
end
