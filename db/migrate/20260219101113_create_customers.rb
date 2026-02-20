class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers, id: :uuid do |t|
      t.string :name, null: false
      t.string :phone_number
      t.decimal :balance, precision: 10, scale: 2, default: 0.0, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    # Adding an index for faster lookups since we will search by name often
    add_index :customers, :name
    add_index :customers, :phone_number, unique: true
  end
end
