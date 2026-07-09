class RemoveFieldsFromVariacions < ActiveRecord::Migration[7.1]
  def change
    change_table :variacions do |t|
      # Removemos las columnas que ya no almacenaremos aquí
      t.remove :descripcion_tp, :ce_beneficiario, :co_concepto, :descripcion_co,
               :in_nomina, :indic_pago, :estatus_concepto, :fe_nomina,
               :fe_efectiva, :fe_efectiva_real, :estatus_deduccion, :mo_concepto,
               :mo_saldo, :status_deduc, :tipo_nomina, :tipo_nomina_especifica,
               :ano, :mes, :indice_concepto
    end
  end
end
