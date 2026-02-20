class Sale < ApplicationRecord
  # Associations
  belongs_to :customer
  belongs_to :user

  # Validations
  validates :liters, :price_per_liter, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  # Before saving, calculate the total
  before_validation :calculate_total_amount

  # After creation, update the customer's debt balance
  after_create :increase_customer_balance

  private

  def calculate_total_amount
    self.total_amount = liters.to_f * price_per_liter.to_f
  end

  def increase_customer_balance
    # We use increment! to safely update the balance in the database
    customer.increment!(:balance, total_amount)
  end
end
