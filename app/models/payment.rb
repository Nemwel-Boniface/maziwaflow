class Payment < ApplicationRecord
  # Associations
  belongs_to :customer
  belongs_to :user

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true

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
end
