class CreateContadors < ActiveRecord::Migration[7.1]
  def change
    create_table :contadors do |t|
      t.string :nombre
      t.integer :valor

      t.timestamps
    end
  end
end
