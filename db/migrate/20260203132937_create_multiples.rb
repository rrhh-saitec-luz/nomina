class CreateMultiples < ActiveRecord::Migration[7.1]
  def change
    create_table :multiples do |t|
      t.integer :ce_trabajador

      t.timestamps
    end
  end
end
