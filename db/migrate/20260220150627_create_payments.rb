class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :payment_method, null: false, default: "Cash"
      t.text :notes
      t.references :customer, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
