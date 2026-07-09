class AddCoConceptoToVariacions < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:variacions, :co_concepto)
      add_column :variacions, :co_concepto, :string
    end
  end
end
