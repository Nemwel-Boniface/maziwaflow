class Payment < ApplicationRecord
  # Associations
  belongs_to :customer
  belongs_to :user

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validate :customer_eligible_for_payment

  # Callbacks
  after_create :reduce_customer_balance
  # Trigger SMS only after the DB transaction is committed
  after_create_commit :trigger_sms

  private

  def reduce_customer_balance
    customer.decrement!(:balance, amount)
  end

  def trigger_sms
    Maziwaflow::TriggerNotificationJob.perform_later(
      record_class: self.class.name,
      record_id: id,
      event: :payment_received
    )
  end

  def customer_eligible_for_payment
    return if customer.blank?

    errors.add(:customer, "must be active") unless customer.active?

    unless customer.sales.exists?
      errors.add(:customer, "must have at least one milk delivery before payment")
    end

    unless customer.balance.to_f.positive?
      errors.add(:customer, "has no outstanding balance to pay")
    end
  end
end
