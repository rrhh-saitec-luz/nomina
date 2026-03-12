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
                   TIPO_NOMINA_ESPECIFICA: params[:tpns])
            .where.not(CO_CONCEPTO: %w[X500 A029 A223 A436])
  end

  # Auxiliares para método: verificar_cargos_multiples
  def colectar_cargos(cargos)
    coleccion = {}
    cargos.each do |t|
      if coleccion.key?(t[0])
        coleccion[t[0]][:cargos] << [t[2], t[3]]
      else
        coleccion[t[0]] = { cedula: t[0], nombre: t[1], cargos: [[t[2], t[3]]] }
      end
    end
    coleccion
  end

  def colectar_cargos_prenomina(cargos)
    coleccion = {}
    cargos.each do |t|
      if coleccion.key?(t[0])
        coleccion[t[0]][:cargos] << [t[1], t[2]]
      else
        coleccion[t[0]] = { cedula: t[0], cargos: [[t[1], t[2]]] }
      end
    end
    coleccion
  end

  def buscar_nomina_actual(multiples)
    Admon.where(ce_trabajador: [multiples])
         .pluck(:ce_trabajador, :nombres, :co_ubicacion, :tipopersonal)
  end

  def buscar_prenomina_actual(multiples)
    HistoricoPago.where(CE_TRABAJADOR: [multiples])
                 .pluck(:CE_TRABAJADOR, :CO_UBICACION, :TIPOPERSONAL).uniq
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

  def buscar_en_admon
    Admon.find_by(co_ubicacion: params[:ubicacion],
                  tipopersonal: params[:personal],
                  ce_trabajador: params[:cedula])
  end

  # Este método solo devolverá el primer elemento encontrado
  def buscar_en_historico
    HistoricoPago.find_by(CO_UBICACION: params[:ubicacion],
                          TIPOPERSONAL: params[:personal],
                          CE_TRABAJADOR: params[:cedula])
  end

  # Éste método devolverá todos los elementos encontrados
  # Importante para actualizar por lotes
  def buscar_en_historico_todos
    HistoricoPago.where(CO_UBICACION: params[:ubicacion],
                        TIPOPERSONAL: params[:tipo],
                        CE_TRABAJADOR: params[:cedula])
  end
end
