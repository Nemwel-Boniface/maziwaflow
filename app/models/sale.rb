class Sale < ApplicationRecord
  # Associations
  belongs_to :customer
  belongs_to :user

  # Validations
  validates :liters, :price_per_liter, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  before_validation :calculate_total_amount
  after_create :increase_customer_balance

  # Trigger SMS only after the DB transaction is committed
  after_create_commit :trigger_sms

  private

  def calculate_total_amount
    self.total_amount = liters.to_f * price_per_liter.to_f
  end

  def increase_customer_balance
    customer.increment!(:balance, total_amount)
  end

  def trigger_sms
    Maziwaflow::TriggerNotificationJob.perform_later(
      record_class: self.class.name,
      record_id: id,
      event: :sale_created
    )
  end
end
