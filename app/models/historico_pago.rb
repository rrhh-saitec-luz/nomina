class HistoricoPago < ApplicationRecord
  alias_attribute :ce_trabajador, :CE_TRABAJADOR
  alias_attribute :co_ubicacion, :CO_UBICACION
  alias_attribute :tipopersonal, :TIPOPERSONAL
  alias_attribute :descripcion_tp, :DESCRIPCION_TP
  alias_attribute :ce_beneficiario, :CE_BENEFICIARIO
  alias_attribute :co_concepto, :CO_CONCEPTO
  alias_attribute :descripcion_co, :DESCRIPCION_CO
  alias_attribute :in_nomina, :IN_NOMINA
  alias_attribute :indicpago, :INDICPAGO
  alias_attribute :estatus_concepto, :ESTATUS_CONCEPTO
  alias_attribute :fe_nomina, :FE_NOMINA
  alias_attribute :fe_efectiva, :FE_EFECTIVA
  alias_attribute :status_deduccion, :STATUS_DEDUCCION
  alias_attribute :mo_concep, :MO_CONCEP
  alias_attribute :mo_saldo, :MO_SALDO
  alias_attribute :status_deduc, :STATUS_DEDUC
  alias_attribute :tipo_nomina, :TIPO_NOMINA
  alias_attribute :tipo_nomina_especifica, :TIPO_NOMINA_ESPECIFICA
  alias_attribute :ano, :ANO
  alias_attribute :mes, :MES
  alias_attribute :indice_concepto, :INDICE_CONCEPTO

  def self.sincronizar_cargos_unicos
    transaction do
      datos_externos.each do |ad|
        cambios = { 'CO_UBICACION' => ad.co_ubicacion,
                    'TIPOPERSONAL' => ad.tipopersonal,
                    'DESCRIPCION_TP' => ad.descripcion_tp }

        where('CE_TRABAJADOR' => ad.ce_trabajador)
          .where('("CO_UBICACION" IS DISTINCT FROM ? OR "TIPOPERSONAL" IS DISTINCT FROM ?)',
                 ad.co_ubicacion,
                 ad.tipopersonal).update_all(cambios)
      end
    end
  end

  def self.sincronizar_cargos_multiples
    transaction do
      datos_externos_multiples.each do |ad|
        actualizados = where(ce_trabajador: ad.ce_trabajador, co_ubicacion: ad.co_ubicacion)
                       .where('tipopersonal IS DISTINCT FROM ?', ad.tipopersonal)
                       .update_all(tipopersonal: ad.tipopersonal, descripcion_tp: ad.descripcion_tp)
        next if actualizados.positive?

        SincronizacionError.find_or_create_by!(
          cedula: ad.ce_trabajador,
          co_ubicacion: ad.co_ubicacion,
          resuelto: false
        ) do |error|
          error.tipo_personal = ad.tipopersonal
          error.mensaje = 'Ubicación cambió o registro no existe en Histórico'
        end
      end
    end
  end

  private

  def self.datos_externos
    Admon.where(edo_cargo: %w[A P])
         .where.not(tipopersonal: '110205')
         .group(:ce_trabajador)
         .having('COUNT(*) = 1')
         .select(
           :ce_trabajador,
           'MAX(co_ubicacion) AS co_ubicacion',
           'MAX(tipopersonal) AS tipopersonal',
           'MAX(descripcion_tp) AS descripcion_tp'
         )
  end

  def self.datos_externos_multiples
    Admon.where(edo_cargo: %w[A P])
         .where.not(tipopersonal: '110205')
         .group(:ce_trabajador, :co_ubicacion)
         .having('COUNT(*) > 1')
         .select(:ce_trabajador, :co_ubicacion, :tipopersonal, :descripcion_tp)
  end
end
