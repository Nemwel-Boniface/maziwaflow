class SalesController < ApplicationController
  before_action :authenticate_user!

  def index
    @per_page = 15
    @page = [ 1, (params[:page] || 1).to_i ].max

    all_sales = Sale.includes(:customer).order(created_at: :desc)
    @total_count = all_sales.count
    @total_pages = (@total_count / @per_page.to_f).ceil

    @sales = all_sales.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    @sale = Sale.find(params[:id])
  end

  def new
    @sale = Sale.new
    # Pre-fill the price per liter if you have a standard rate (e.g., 60)
    @sale.price_per_liter = 60.0
  end

  def create
    @sale = current_user.sales.build(sale_params)

    respond_to do |format|
      if @sale.save
        customer_name = @sale.customer&.name || "Customer"
        customer_balance = @sale.customer&.balance

        format.html do
          redirect_to sales_path,
            notice: "Sale created and SMS sent to #{customer_name}. Dues owed: KES #{customer_balance}.",
            status: :see_other
        end
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def sale_params
    params.require(:sale).permit(:customer_id, :liters, :price_per_liter, :notes)
  end
end
