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
  end

  private

  def buscar_conceptos
    Concepto.where(CE_TRABAJADOR: params[:CE_TRABAJADOR])
            .where(CO_UBICACION: params[:CO_UBICACION])
            .where(TIPOPERSONAL: params[:TIPOPERSONAL])
  end

  def calculo_de_quincenas(nomina)
    indices_de_conceptos = nomina.group_by { |concepto| concepto[:INDICE_CONCEPTO] }
    segunda_quincena = indices_de_conceptos['A'].sum(&:MO_CONCEP) - indices_de_conceptos['X'].sum(&:MO_CONCEP)
    [primera_quincena, segunda_quincena]
  end

  def mostrar_nomina(conceptos)
    conceptos.where(ANO: params[:ano], MES: params[:mes])
  end
end
