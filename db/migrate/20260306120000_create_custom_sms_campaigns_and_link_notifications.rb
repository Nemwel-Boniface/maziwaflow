class CreateCustomSmsCampaignsAndLinkNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_sms_campaigns, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :audience, null: false
      t.text :body, null: false

      t.timestamps
    end

    add_reference :sms_notifications, :custom_sms_campaign, type: :uuid, foreign_key: true
    add_index :custom_sms_campaigns, :created_at
  end
end
