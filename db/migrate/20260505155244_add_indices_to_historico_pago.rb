class AddIndicesToHistoricoPago < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  def change
    add_index :historico_pagos, 'CO_UBICACION',
              algorithm: :concurrently,
              name: 'index_hp_on_co_ubicacion'

    # Índice para TIPOPERSONAL
    add_index :historico_pagos, 'TIPOPERSONAL',
              algorithm: :concurrently,
              name: 'index_hp_on_tipopersonal'
  end
end
