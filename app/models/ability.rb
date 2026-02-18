class Ability
  include CanCan::Ability

  def initialize(admin)
    # admin may be nil if not signed in
    return unless admin.present?

    if admin.has_role?(:owner) || admin.has_role?(:admin)
      can :manage, :all
    else
      # default fallback: read access to customers, no destructive actions
      can :read, Customer
    end
  end
end
