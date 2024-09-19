class CreateTabTrabajadors < ActiveRecord::Migration[7.1]
  def change
    create_table :tab_trabajadors do |t|
      t.integer :cedula
      t.string :nombre1
      t.string :nombre2
      t.string :apellido1
      t.string :apellido2
      t.date :fecha_de_nac

      t.timestamps
    end
    add_index :tab_trabajadors, :cedula, unique: true
  end
end
