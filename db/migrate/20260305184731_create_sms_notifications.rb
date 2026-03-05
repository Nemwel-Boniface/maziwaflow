class CreateSmsNotifications < ActiveRecord::Migration[8.1]
  def change
    # This ensures that UUID support is enabled in the database
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :sms_notifications, id: :uuid do |t|
      # Polymorphic link using UUID to Sale, Payment, etc.
      t.references :notifiable, polymorphic: true, type: :uuid, null: false, index: true

      t.string :event, null: false              # e.g., 'sale_created'
      t.string :phone_number, null: false
      t.text :message, null: false
      t.string :status, default: "pending", null: false
      t.string :provider_message_id             # Africa's Talking Message ID
      t.text :error                             # Failure details
      t.datetime :sent_at

      t.timestamps
    end

    # Index status for fast filtering in the admin dashboard
    add_index :sms_notifications, :status
    add_index :sms_notifications, :event
  end
end
