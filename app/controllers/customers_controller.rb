class CustomersController < ApplicationController
  before_action :authenticate_user!

  def index
    @customers = Customer.ordered
  end

  def toggle_active
    @customer = Customer.find(params[:id])

    # If trying to DEACTIVATE (current is true) while they owe money
    if @customer.active && @customer.balance > 0
      redirect_to customer_path(@customer), alert: "Cannot deactivate customer with an outstanding balance of KES #{@customer.balance}."
      return
    end

    if @customer.update(active: !@customer.active)
      redirect_back fallback_location: customers_path, notice: "Status updated for #{@customer.name}."
    else
      redirect_back fallback_location: customers_path, alert: "Update failed."
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
