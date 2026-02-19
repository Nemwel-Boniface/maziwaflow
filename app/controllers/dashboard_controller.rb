class DashboardController < ApplicationController
  load_and_authorize_resource class: :false
  def index
    @total_customers = Customer.active.count

    # Sum of all the liters sold today
    @total_liters_today = Sale.where(created_at: Time.zone.now.all_day).sum(:liters)

    @outstanding_debt = Customer.sum(:balance)

    # Fetch the total number of staff who are not the one who is loogegd in
    @staff_count = User.where.not(id: current_user.id).count
  end
end
