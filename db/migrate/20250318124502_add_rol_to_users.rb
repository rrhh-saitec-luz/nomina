class AddRolToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :rol, :string, default: 'operador'
  end
end
