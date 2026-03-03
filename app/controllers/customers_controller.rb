class CustomersController < ApplicationController
  before_action :authenticate_user!

  def index
    @per_page = 15
    @page = [ 1, (params[:page] || 1).to_i ].max
    @query = params[:query].to_s.strip
    @status_filter = params[:status].to_s
    @owes_only = params[:owes_only] == "1"

    all_customers = Customer.ordered

    if @query.present?
      all_customers = all_customers.where("name ILIKE :query OR phone_number ILIKE :query", query: "%#{@query}%")
    end

    case @status_filter
    when "active"
      all_customers = all_customers.where(active: true)
    when "inactive"
      all_customers = all_customers.where(active: false)
    end

    all_customers = all_customers.where("balance > 0") if @owes_only

    @customer_name_suggestions = Customer.ordered.limit(100).pluck(:name)
    @total_count = all_customers.count
    @total_pages = (@total_count / @per_page.to_f).ceil

    @customers = all_customers.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def toggle_active
    @customer = Customer.find(params[:id])

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

    # Chart Data
    @liters_history = @customer.sales.group_by_day(:created_at, last: 30).sum(:liters)
    @payments_history = @customer.payments.group_by_day(:created_at, last: 30).sum(:amount)

    # Paginate Sales
    @sales_per_page = 10
    @sales_page = [ 1, (params[:sales_page] || 1).to_i ].max
    all_sales = @customer.sales.order(created_at: :desc)
    @sales_total_pages = (all_sales.count / @sales_per_page.to_f).ceil
    @recent_sales = all_sales.offset((@sales_page - 1) * @sales_per_page).limit(@sales_per_page)

    # Paginate Payments
    @payments_per_page = 10
    @payments_page = [ 1, (params[:payments_page] || 1).to_i ].max
    all_payments = @customer.payments.order(created_at: :desc)
    @payments_total_pages = (all_payments.count / @payments_per_page.to_f).ceil
    @recent_payments = all_payments.offset((@payments_page - 1) * @payments_per_page).limit(@payments_per_page)
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      redirect_to customers_path, notice: "Customer created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :phone_number, :active)
  end
end
