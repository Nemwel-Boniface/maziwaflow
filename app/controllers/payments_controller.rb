class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @per_page = 15
    @page = (params[:page] || 1).to_i

    all_payments = Payment.includes(:customer, :user).order(created_at: :desc)
    @total_count = all_payments.size
    @total_pages = (@total_count / @per_page.to_f).ceil

    @payments = all_payments.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    @payment = Payment.find(params[:id])
  end

  def new
    @payment = Payment.new
    # If coming from a specific customer page later, we can pre-select them
    @payment.customer_id = params[:customer_id]
  end

  def create
    @payment = current_user.payments.build(payment_params)

    respond_to do |format|
      if @payment.save
        format.html { redirect_to payments_path, notice: "Payment recorded and balance updated.", status: :see_other }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:customer_id, :amount, :payment_method, :notes)
  end
end
