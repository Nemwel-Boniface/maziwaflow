class CustomersController < ApplicationController
  before_action :authenticate_user!

  def index
    @customers = Customer.ordered
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
