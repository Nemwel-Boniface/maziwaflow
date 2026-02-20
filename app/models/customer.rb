class Customer < ApplicationRecord
  # associations
  has_many :sales, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :phone_number, uniqueness: true, allow_blank: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(name: :asc) }
end
