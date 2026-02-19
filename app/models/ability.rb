class Ability
  include CanCan::Ability

  def initialize(user)
    # Handle guests (not logged in)
    return unless user.present?

    if user.has_role?(:admin)
      # Full access for the Milkman
      can :manage, :all
    elsif user.has_role?(:staff)
      # Staff can manage sales and customers, but maybe not delete users
      # We will refine this once the tables exist
      can :read, :all
    else
      # Default fallback for a new user with no role yet
      # They can see the dashboard but nothing else
      can :read, :dashboard
    end
  end
end
