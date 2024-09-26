class CreateTabTrabajadors < ActiveRecord::Migration[7.1]
  def change
    create_table :tab_trabajadors do |t|
      t.integer :cedula, null: false
      t.string :nombre1, null: false
      t.string :nombre2, default: ''
      t.string :apellido1, null: false
      t.string :apellido2, default: ''
      t.date :fecha_de_nac, null: false

      t.timestamps
    end
    add_index :tab_trabajadors, :cedula, unique: true
  end
end
