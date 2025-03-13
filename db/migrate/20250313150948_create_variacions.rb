# Frozen_string_literal: true

# clase para manejar variaciones
class CreateVariacions < ActiveRecord::Migration[7.1]
  def change
    create_table :variacions do |t|
      t.integer :ce_trabajador
      t.string :co_ubicacion
      t.string :tipopersonal
      t.string :descripcion_tp
      t.integer :ce_beneficiario
      t.string :co_concepto
      t.string :descripcion_co
      t.string :in_nomina
      t.string :inicpago
      t.string :estatus_concepto
      t.date :fe_nomina
      t.date :fe_efectiva
      t.date :fe_efectiva_real
      t.numeric :estatus_deduccion
      t.numeric :mo_concepto
      t.numeric :mo_saldo
      t.numeric :status_deduc
      t.integer :tipo_nomina
      t.integer :tipo_nomina_especifica
      t.integer :ano
      t.integer :mes
      t.string :indice_concepto
      t.string :usuario
      t.timestamps
    end
  end
end
