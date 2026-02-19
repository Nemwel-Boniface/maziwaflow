class DashboardController < ApplicationController
  load_and_authorize_resource class: :false
  def index
    @total_customers = Customer.active.count
    @total_liters_today = 0
    @outstanding_debt = Customer.sum(:balance)

    # Fetch the total number of staff who are not the one who is loogegd in
    @staff_count = User.where.not(id: current_user.id).count
  end
end
