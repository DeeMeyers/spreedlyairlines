class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.string :flight_name
      t.string :date
      t.string :last_four
      t.float :amount
      t.boolean :saved
      t.string :gateway_type

      t.timestamps
    end
  end
end
