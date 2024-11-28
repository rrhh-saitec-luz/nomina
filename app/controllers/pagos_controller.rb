# Frozen_string_literal: true

# Clase para manejar información del trabajador
class PagosController < ApplicationController
  def index
    @conceptos = Concepto.all
    @asignaciones = asignaciones(@conceptos)
  end

  def show
    @conceptos_trabajador = Concepto.where(CE_TRABAJADOR: 18_987_722)
    @asignaciones_trabajador = asignaciones(@conceptos_trabajador)
  end

  private

  def asignaciones(conceptos)
    suma_asignaciones = 0
    suma_deducciones = 0
    conceptos.each do |concepto|
      if concepto.INDICE_CONCEPTO.eql?('A')
        suma_asignaciones += concepto.MO_CONCEP
      else
        suma_deducciones += concepto.MO_CONCEP
      end
    end
    { 'total_asignacion' => suma_asignaciones, 'total_deducciones' => suma_deducciones }
  end
end
