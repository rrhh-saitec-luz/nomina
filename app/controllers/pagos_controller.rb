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
    @meses_disponibles = buscar_lapso(@conceptos_trabajador, :MES)
    @años_disponibles = buscar_lapso(@conceptos_trabajador, :ANO)
    @periodo = { 'Año' => params[:ano], 'Mes' => params[:mes] }
    @nomina_mes = mostrar_nomina(@conceptos_trabajador)
    @trabajador = Admon.find(params[:id])
    @quincenas = calcular_quincenas(@nomina_mes)
  end

  def variaciones
    @trabajador = Admon.find(params[:id])
    @conceptos_trabajador = buscar_conceptos
    @conceptos = conceptos_disponibles(@conceptos_trabajador)
  end

  private

  def conceptos_disponibles(conceptos)
    conceptos.select(:DESCRIPCION_CO, :CO_CONCEPTO, :MO_CONCEP)
             .group(:CO_CONCEPTO, :DESCRIPCION_CO, :MO_CONCEP)
  end

  def buscar_conceptos
    Concepto.where(CE_TRABAJADOR: params[:CE_TRABAJADOR])
            .where(CO_UBICACION: params[:CO_UBICACION])
            .where(TIPOPERSONAL: params[:TIPOPERSONAL])
  end

  def buscar_lapso(conceptos, ciclo)
    conceptos.select(ciclo).distinct.pluck(ciclo)
  end

  def mostrar_nomina(conceptos)
    conceptos.where(ANO: params[:ano], MES: params[:mes])
  end

  def calcular_quincenas(nomina_mes)
    primera_quincena = nomina_mes.find { |concepto| concepto.CO_CONCEPTO == 'X500' }
    conceptos_por_indices = indices(nomina_mes)
    suma_conceptos = suma_de_conceptos(conceptos_por_indices)
    [primera_quincena, suma_conceptos.values]
  end

  def indices(nomina)
    nomina.group_by { |indice| indice[:INDICE_CONCEPTO] }
  end

  def suma_de_conceptos(indices)
    suma_concepto = {}
    indices.each do |indice, conceptos|
      suma_concepto[indice] = conceptos.reduce(0) do |suma, concepto|
        suma + concepto.MO_CONCEP
      end
    end
    suma_concepto
  end
end
