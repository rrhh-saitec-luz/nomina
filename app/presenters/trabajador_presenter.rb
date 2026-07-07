# frozen_string_literal: true

# presentador para las vistas
class TrabajadorPresenter < SimpleDelegator
  include ActionView::Helpers::UrlHelper
  include Constantes

  def initialize(trabajador)
    super(trabajador)
  end

  def datos_personales
    { 'Nombre del Trabajador:' => nombres,
      'Cédula del Trabajador:' => ce_trabajador,
      'Estatus del Trabajador:' => DESCRIPCION_DE_ESTADOS[estatus] }
  end

  def datos_cargo
    { 'Ubicación:' => [co_ubicacion, descripcion_larga],
      'Tipo de Personal:' => [tipopersonal, descripcion_tp],
      'Dedicación:' => [dedicacion, desc_dedicacion],
      'Código Cargo:' => [co_cargo, descripcion_cargo],
      'Categoría/Grado:' => [co_categrado, desc_categrado],
      'Escala Nivel:' => [gdosalarial],
      'Estatus Cargo:' => [DESCRIPCION_DE_ESTADOS[edo_cargo]],
      'Principal:' => [DESCRIPCION_PRINCIPAL[principal]] }
  end

  def datos_ingreso
    { 'Tipo de Ingreso:' => [co_ingreso, des_co_ingreso],
      'Fecha de Oficio:' => [fecha_oficio_formateada],
      'No. de Oficio:' => [nu_oficio],
      'Cédula sustituto:' => [ce_sustituto],
      'Texto Carta:' => [texto_carta] }
  end

  # --- NUEVOS MÉTODOS MIGRADOS ---

  def fechas_gral_cargo
    formatear_hash_fechas({ 'Ingreso a LUZ:' => fe_ingreso,
                            'Ingreso Nómina:' => fe_ingreso_nomina,
                            'Jubilación/Pensión:' => fe_jubilacion,
                            'Retiro Efectivo:' => fe_retiro,
                            'Retiro Nómina:' => fe_retiro,
                            'Fecha de Finiquito:' => nil,
                            'Fallecimiento:' => fe_efectiva2 })
  end

  def fechas_adm_cargo
    formatear_hash_fechas({ 'Real:' => fe_reacat,
                            'Administrativa:' => fe_admcat,
                            'Inicio Contrato:' => fe_inicontrato,
                            'Fin Contrato:' => fe_fincontrato,
                            'Inicio Adm. Pública:' => fe_adm_publica,
                            'Fin Adm. Pública:' => fe_fin_adm_publica,
                            'Nombramiento:' => fe_nombramiento })
  end

def antiguedad
  fecha_final = fe_efectiva || fe_jubilacion || retiro_efectivo || Date.today
  fecha_inicio = fe_ingreso
  
  # Temporal: Esto nos mostrará las dos fechas en la vista para ver el misterio
  return "Inicio: #{fecha_inicio&.strftime('%Y-%m-%d')} | Final: #{fecha_final&.strftime('%Y-%m-%d')}"
  
  # (El resto del código se queda igual abajo...)
end
  def turno_actual
    HORARIOS[horario] || 'No asignado'
  end

  private

  def check_fecha_final
    return fe_efectiva unless fe_efectiva.nil?
    return fe_jubilacion unless fe_jubilacion.nil?
    return retiro_efectivo unless retiro_efectivo.nil?

    Date.today
  end

  def fecha_oficio_formateada
    fe_docoficio.nil? ? '00/00/0000' : fe_docoficio.strftime('%d/%m/%Y')
  end

  # Formatea automáticamente todas las fechas de un Hash a '%d/%m/%Y' o '00/00/0000'
  def formatear_hash_fechas(hash_fechas)
    hash_fechas.transform_values do |fecha|
      fecha.nil? ? '00/00/0000' : fecha.strftime('%d/%m/%Y')
    end
  end

  def check_month?(fechas)
    fechas[0].month < fechas[1].month
  end
end
