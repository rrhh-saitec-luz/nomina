class RenameInicpagoToIndicpago < ActiveRecord::Migration[7.1]
  def change
    rename_column :variacions, :inicpago, :indic_pago
  end
end
