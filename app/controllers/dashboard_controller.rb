class DashboardController < ApplicationController
  def index
    @total_customers = 0
    @total_litres_today = 0
    @debt_outstanding = 0
  end
end
