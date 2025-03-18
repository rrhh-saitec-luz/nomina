class AddAccionToVariacions < ActiveRecord::Migration[7.1]
  def change
    add_column :variacions, :accion, :string
  end
end
