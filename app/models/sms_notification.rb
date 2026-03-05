class SmsNotification < ApplicationRecord
  # The notifiable is the specific Sale or Payment record
  belongs_to :notifiable, polymorphic: true

  validates :event, :phone_number, :message, :status, presence: true

  # Status constants for cleaner logic
  STATUSES = %w[pending queued sent failed].freeze

  scope :pending, -> { where(status: "pending") }
  scope :sent, -> { where(status: "sent") }
  scope :failed, -> { where(status: "failed") }
  scope :recent, -> { order(created_at: :desc) }
end
