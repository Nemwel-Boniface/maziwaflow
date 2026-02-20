class SalesController < ApplicationController
  before_action :authenticate_user!

  def index
    @sales = Sale.includes(:customer).order(created_at: :desc)
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
        format.html { redirect_to sales_path, notice: "Sale recorded successfully.", status: :see_other }
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
