# Frozen_string_literal: true

# Modulo para ayudar el controlador Admin y almacenar otros métodos secundarios
module AdminConcerns
  extend ActiveSupport::Concern

  # Métodos para eliminar trabajadores inactivos o actualizar activos que cambiaron
  def activos
    Admon.where(edo_cargo: %w[A P])
         .where.not(tipopersonal: '110205')
         .map { |t| [t.ce_trabajador, t.co_ubicacion.strip, t.tipopersonal.strip] }
  end

  def cargos_en_nomina
    HistoricoPago.select(:CE_TRABAJADOR, :CO_UBICACION, :TIPOPERSONAL)
                 .map { |c| [c.CE_TRABAJADOR, c.CO_UBICACION.strip, c.TIPOPERSONAL.strip] }.uniq
  end

  def inactivos
    Admon.where.not(edo_cargo: %w[A P])
         .map { |t| [t.ce_trabajador, t.co_ubicacion.strip, t.tipopersonal.strip] }
  end

  # Métodos para actualizar la prenomina
  def actualizar_prenomina
    mes = params[:mes]
    year = params[:year]
    fecha = params[:fecha]
    update_prenomina(mes, year, fecha)
    sumar_contador(contador_depurar) if contador_depurar.map(&:valor).first.eql?(1)
    modificar_prenomina
  end

  def update_prenomina(mes, year, fecha)
    fe_efectiva = Date.parse(fecha) + 21
    HistoricoPago.update_all(MES: mes,
                             ANO: year,
                             FE_NOMINA: fecha,
                             FE_EFECTIVA: fe_efectiva)
  end

  # Métodos para crear la prenomina
  def prenomina_params
    Concepto.where(ANO: params[:year],
                   MES: params[:month],
                   TIPO_NOMINA: params[:tpn],
                   TIPO_NOMINA_ESPECIFICA: params[:tpns]).where.not(CO_CONCEPTO: %w[X500 A029 A223 A436])
  end

  # Métodos auxiliares
  def concepto_pluck(campo)
    Concepto.all.select(campo).distinct.pluck(campo)
  end

  def sumar_contador(contador)
    nuevo_valor = contador.map(&:valor).first
    contador.update(valor: nuevo_valor + 1)
  end

  def reiniciar_contador(contador)
    contador.update(valor: 0)
  end

  def contador_depurar
    Contador.where(nombre: 'depurar')
  end

  def crear_cargos_multiples(cargos_multiples)
    cargos_multiples.each { |t| Multiple.create(ce_trabajador: t) }
  end
end
