# Frozen_string_literal: true

# Clase para manejar información del trabajador
class PagosController < ApplicationController
  def index
    @conceptos = Concepto.select(:INDICE_CONCEPTO, :MO_CONCEP).all
    @cantidad_trabajadores = Concepto.select(:CE_TRABAJADOR).distinct.count
    @asignaciones = asignaciones(@conceptos)
  end

  def show
    @conceptos_trabajador = buscar_conceptos
    @meses_disponibles = @conceptos_trabajador.select(:MES).distinct.pluck(:MES)
    @años_disponibles = @conceptos_trabajador.select(:ANO).distinct.pluck(:ANO)
    @nomina_mes = mostrar_nomina(@conceptos_trabajador)
    @asignaciones_trabajador = asignaciones(@conceptos_trabajador)
  end

  private

  def buscar_conceptos
    Concepto.where(CE_TRABAJADOR: params[:CE_TRABAJADOR])
            .where(CO_UBICACION: params[:CO_UBICACION])
            .where(TIPOPERSONAL: params[:TIPOPERSONAL])
  end

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

  def mostrar_nomina(conceptos)
    conceptos.where(ANO: params[:ano], MES: params[:mes])
  end
end
