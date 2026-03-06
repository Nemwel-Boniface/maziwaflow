class Customer < ApplicationRecord
  # associations
  has_many :sales, dependent: :destroy
  has_many :payments, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :phone_number, uniqueness: true, allow_blank: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :with_deliveries, -> { joins(:sales).distinct }
  scope :ordered, -> { order(name: :asc) }

  # Callbacks
  after_create_commit :trigger_welcome_sms
  after_update_commit :trigger_deactivation_sms, if: :deactivated?

  private

  def trigger_welcome_sms
    Maziwaflow::TriggerNotificationJob.perform_later(
      record_class: self.class.name,
      record_id: id,
      event: :customer_created
    )
  end

  def trigger_deactivation_sms
    Maziwaflow::TriggerNotificationJob.perform_later(
      record_class: self.class.name,
      record_id: id,
      event: :customer_deactivated
    )
  end

  def deactivated?
    saved_change_to_active? && !active?
  end
end
