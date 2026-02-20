class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @payments = Payment.includes(:customer, :user).order(created_at: :desc)
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
