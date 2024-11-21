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

  def calculo_de_antiguedad(trabajador)
    fecha_final = check_fecha_final(trabajador)
    fecha_inicio = trabajador.fe_ingreso
    fechas = [fecha_final, fecha_inicio]

    return 0 if fecha_inicio.year == fecha_final.year

    antiguedad = fecha_final.year - fecha_inicio.year

    if check_month?(fechas) || (fecha_final.month == fecha_inicio.month && fecha_final.day < fecha_inicio.day)
      antiguedad -= 1
    end

    antiguedad
  end

  def check_month?(fechas)
    fechas[0].month < fechas[1].month
  end

  def check_fecha_final(trabajador)
    return trabajador.fe_efectiva unless trabajador.fe_efectiva.nil?
    return trabajador.fe_jubilacion unless trabajador.fe_jubilacion.nil?
    return trabajador.retiro_efectivo unless trabajador.retiro_efectivo.nil?

    Date.today
  end

  def fechas_gral_cargo(trabajador)
    {  'Ingreso a LUZ:' => trabajador.fe_ingreso,
       'Ingreso Nómina:' => trabajador.fe_ingreso_nomina,
       'Jubilación/Pensión:' => trabajador.fe_jubilacion,
       'Retiro Efectivo:' => trabajador.fe_retiro,
       'Retiro Nómina:' => trabajador.fe_retiro,
       'Fecha de Finiquito:' => nil,
       'Fallecimiento:' => trabajador.fe_efectiva2 }
  end

  def fechas_adm_cargo(trabajador)
    {  'Real:' => trabajador.fe_reacat,
       'Administrativa:' => trabajador.fe_admcat,
       'Inicio Contrato:' => trabajador.fe_inicontrato,
       'Fin Contrato:' => trabajador.fe_fincontrato,
       'Inicio Adm. Pública:' => trabajador.fe_adm_publica,
       'Fin Adm. Pública:' => trabajador.fe_fin_adm_publica,
       'Nombramiento:' => trabajador.fe_nombramiento }
  end

  def datos_cargo_trabajador(trabajador)
    {  'Ubicación:' => [trabajador.co_ubicacion, trabajador.descripcion_larga],
       'Tipo de Personal:' => [trabajador.tipopersonal, trabajador.descripcion_tp],
       'Dedicación:' => [trabajador.dedicacion, trabajador.desc_dedicacion],
       'Código Cargo:' => [trabajador.co_cargo, trabajador.descripcion_cargo],
       'Categoría/Grado:' => [trabajador.co_categrado, trabajador.desc_categrado],
       'Escala Nivel:' => [trabajador.gdosalarial],
       'Estatus Cargo:' => [DESCRIPCION_DE_ESTADOS[trabajador.edo_cargo]],
       'Principal:' => [DESCRIPCION_PRINCIPAL[trabajador.principal]] }
  end

  def datos_personales(trabajador)
    {  'Nombre del Trabajador:' => trabajador.nombres,
       'Cédula del Trabajador:' => trabajador.ce_trabajador,
       'Estatus del Trabajador:' => DESCRIPCION_DE_ESTADOS[trabajador.estatus] }
  end

  def ingreso_trabajador(trabajador)
    fecha_oficio = if trabajador.fe_docoficio.nil?
                     '00/00/0000'
                   else
                     trabajador.fe_docoficio.strftime('%d/%m/%Y')
                   end
    {  'Tipo de Ingreso:' => [trabajador.co_ingreso, trabajador.des_co_ingreso],
       'Fecha de Oficio:' => [fecha_oficio],
       'No. de Oficio:' => [trabajador.nu_oficio],
       'Cédula sustituto:' => [trabajador.ce_sustituto],
       'Texto Carta:' => [trabajador.texto_carta] }
  end
end
