class RemoveIdTrabajadorFromVariacion < ActiveRecord::Migration[7.1]
  def change
    remove_column :variacions, :id_trabajador, :integer
  end
end
