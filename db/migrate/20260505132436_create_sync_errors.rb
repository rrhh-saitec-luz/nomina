class CreateSyncErrors < ActiveRecord::Migration[7.1]
  def change
    create_table :sync_errors do |t|
      t.string :ce_trabajador
      t.string :co_ubicacion
      t.string :tipo_personal
      t.string :mensaje
      t.boolean :resuelto, default: false

      t.timestamps
    end
  end
end
