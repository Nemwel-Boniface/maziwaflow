class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  # Callbacks
  after_create :assign_default_role

  private

  def assign_default_role
    # Assign the default role of :staff to all new users
    self.add_role(:staff) if self.roles.blank?
  end
end
