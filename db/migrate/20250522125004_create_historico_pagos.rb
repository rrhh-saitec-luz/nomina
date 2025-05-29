class CreateHistoricoPagos < ActiveRecord::Migration[7.1]
  def change
    create_table :historico_pagos do |t|
      t.integer :CE_TRABAJADOR
      t.string :CO_UBICACION
      t.string :TIPOPERSONAL
      t.string :DESCRIPCION_TP
      t.integer :CE_BENEFICIARIO
      t.string :CO_CONCEPTO
      t.string :DESCRIPCION_CO
      t.string :IN_NOMINA
      t.string :INDICPAGO
      t.string :ESTATUS_CONCEPTO
      t.date :FE_NOMINA
      t.date :FE_EFECTIVA
      t.numeric :STATUS_DEDUCCION
      t.numeric :MO_CONCEPTO
      t.numeric :MO_SALDO
      t.numeric :STATUS_DEDUC
      t.integer :TIPO_NOMINA
      t.integer :TIPO_NOMINA_ESPECIFICA
      t.integer :ANO
      t.integer :MES
      t.string :INDICE_CONCEPTO
      t.timestamps
    end
  end
end
