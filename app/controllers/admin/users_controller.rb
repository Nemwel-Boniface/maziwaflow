class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @users = User.includes(:roles).where.not(id: current_user.id).order(created_at: :desc)
  end

  def toggle_admin
    user = User.find(params[:id])

    if user.has_role?(:admin)
      user.remove_role(:admin)
    else
      user.add_role(:admin)
    end

    redirect_to admin_users_path, notice: "Updated admin rights for #{user.email}."
  end

  def toggle_active
    user = User.find(params[:id])
    # Toggling the boolean value
    if user.update(active: !user.active)
      redirect_to admin_users_path, notice: "Updated active status for #{user.email}."
    else
      redirect_to admin_users_path, alert: "Could not update active status."
    end
  end

  private

  def require_admin!
    unless current_user.has_role?(:admin)
      redirect_to dashboard_path, alert: "You are not authorized to view that page."
    end
  end
end
