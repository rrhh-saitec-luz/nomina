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
end
