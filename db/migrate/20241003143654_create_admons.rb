class CreateAdmons < ActiveRecord::Migration[7.1]
  def change
    create_table :admons do |t|

      t.timestamps
    end
  end
end
