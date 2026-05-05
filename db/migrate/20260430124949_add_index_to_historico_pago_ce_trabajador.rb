class AddIndexToHistoricoPagoCeTrabajador < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # Usamos comillas dobles porque el nombre de la columna está en MAYÚSCULAS
    add_index :historico_pagos, 'CE_TRABAJADOR', algorithm: :concurrently, name: 'index_hp_on_ce_trabajador'
  end
end
