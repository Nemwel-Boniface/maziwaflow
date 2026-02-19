class DashboardController < ApplicationController
  load_and_authorize_resource class: :false
  def index
    @total_customers = 0
    @total_litres_today = 0
    @debt_outstanding = 0

    # Fetch the total number of staff who are not the one who is loogegd in
    @staff_count = User.where.not(id: current_user.id).count
  end
end
