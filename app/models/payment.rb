class Payment < ApplicationRecord
  belongs_to :customer
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true

  # After recording a payment, reduce the customer's balance
  after_create :reduce_customer_balance

  private

  def reduce_customer_balance
    # Using decrement! to subtract the amount from the customer's balance
    customer.decrement!(:balance, amount)
  end
end
