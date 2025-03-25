class AddIdTrabajdorToVariacion < ActiveRecord::Migration[7.1]
  def change
    add_column :variacions, :id_trabajador, :integer
  end
end
