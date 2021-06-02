class CreateFlights < ActiveRecord::Migration[5.2]
  def change
    create_table :flights do |t|
      t.string :route
      t.float :price

      t.timestamps
    end
  end
end
