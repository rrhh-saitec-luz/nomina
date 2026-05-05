# frozen_string_literal: true

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

  def self.detectar_inconsistencias_multiples
    datos_externos_multiples.each do |ad|
      existe = where(
        '"CE_TRABAJADOR" = ? AND "CO_UBICACION" = ? AND "TIPOPERSONAL" = ?',
        ad.ce_trabajador, ad.co_ubicacion, ad.tipopersonal
      ).exists?
      next if existe

      SyncError.find_or_create_by!(
        ce_trabajador: ad.ce_trabajador,
        co_ubicacion: ad.co_ubicacion,
        tipo_personal: ad.tipopersonal,
        resuelto: false
      ) do |error|
        error.mensaje = 'Cargo múltiple no encontrado en Histórico: verificar ubicación o jubilación'
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
         .select(:ce_trabajador,
                 :co_ubicacion,
                 'MAX(tipopersonal) AS tipopersonal',
                 'MAX(descripcion_tp) AS descripcion_tp')
  end
end
