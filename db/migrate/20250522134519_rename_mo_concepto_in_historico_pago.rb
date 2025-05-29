class RenameMoConceptoInHistoricoPago < ActiveRecord::Migration[7.1]
  def change
    rename_column :historico_pagos, :MO_CONCEPTO, :MO_CONCEP
  end
end
