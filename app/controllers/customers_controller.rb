class CustomersController < ApplicationController
  before_action :authenticate_user!

  def index
    @customers = Customer.ordered
  end

  def toggle_active
    customer = Customer.find(params[:id])
    # Toggling the boolean value
    if customer.update(active: !customer.active)
      redirect_to customers_path, notice: "Updated active status for #{customer.name}."
    else
      redirect_to customers_path, alert: "Could not update active status."
    end
  end

  def show
    @customer = Customer.find(params[:id])

    # Data to be used by the charts
    @liters_history = @customer.sales.group_by_day(:created_at, last: 30).sum(:liters)
    @payments_history = @customer.payments.group_by_day(:created_at, last: 30).sum(:amount)

    # Recent  sales and payments for the customer
    @recent_sales = @customer.sales.order(created_at: :desc).limit(5)
    @recent_payments = @customer.payments.order(created_at: :desc).limit(5)
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to customers_path, notice: "Customer created successfully.", status: :see_other }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :phone_number, :active)
  end
end
