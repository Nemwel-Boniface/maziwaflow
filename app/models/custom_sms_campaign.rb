class CustomSmsCampaign < ApplicationRecord
  AUDIENCES = %w[all selected].freeze

  belongs_to :sender, class_name: "User"
  has_many :sms_notifications, dependent: :nullify

  validates :body, presence: true
  validates :audience, inclusion: { in: AUDIENCES }

  scope :recent, -> { order(created_at: :desc) }

  def sent_count
    sms_notifications.where(status: "sent").count
  end

  def failed_count
    sms_notifications.where(status: "failed").count
  end
end
