class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  # Associations
  has_many :sales, dependent: :nullify
  has_many :payments, dependent: :nullify

  # Callbacks
  after_create :assign_default_role

  # Only allow login for active users
  def active_for_authentication?
    super && active?
  end

  # Provide a clearer Devise message when a user is inactive
  def inactive_message
    active? ? super : :inactive
  end

  private

  def assign_default_role
    # Assign the default role of :staff to all new users
    self.add_role(:staff) if self.roles.blank?
  end
end
