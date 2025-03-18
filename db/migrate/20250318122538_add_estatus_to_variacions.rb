# Frozen_string_literal: true

# Agrega columna de status a el modelo variacions
class AddEstatusToVariacions < ActiveRecord::Migration[7.1]
  def change
    add_column :variacions, :status, :boolean, default: false
  end
end
