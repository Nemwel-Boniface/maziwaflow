class CreateSales < ActiveRecord::Migration[8.1]
  def change
    create_table :sales, id: :uuid do |t|
      t.references :customer, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.decimal :liters, precision: 10, scale: 2, null: false
      t.decimal :price_per_liter, precision: 10, scale: 2, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.text :notes

      t.timestamps
    end
  end
end
