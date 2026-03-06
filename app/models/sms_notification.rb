class SmsNotification < ApplicationRecord
  # Polymorphic relationship to Sales, Payments, etc.
  belongs_to :notifiable, polymorphic: true
  belongs_to :custom_sms_campaign, optional: true

  STATUSES = %w[pending queued sent failed].freeze

  # Validations
  validates :status, inclusion: { in: STATUSES }
  validates :phone_number, :message, :event, presence: true

  # Callbacks
  before_validation :set_default_status, on: :create

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :failed, -> { where(status: "failed") }

  def success?
    status == "sent"
  end

  def failed?
    status == "failed"
  end

  private

  def set_default_status
    self.status ||= "pending"
  end
end
