class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @per_page = 15
    @page = [ 1, (params[:page] || 1).to_i ].max
    @date_filter = params[:date_filter].to_s
    @customer_query = params[:customer_query].to_s.strip
    @payment_method = params[:payment_method].to_s.strip
    @start_date = params[:start_date].to_s
    @end_date = params[:end_date].to_s

    all_payments = Payment.includes(:customer, :user).order(created_at: :desc)

    if @customer_query.present?
      all_payments = all_payments.joins(:customer).where("customers.name ILIKE ?", "%#{@customer_query}%")
    end

    if @payment_method.present?
      all_payments = all_payments.where(payment_method: @payment_method)
    end

    case @date_filter
    when "this_week"
      all_payments = all_payments.where(created_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week)
    when "last_week"
      last_week = 1.week.ago
      all_payments = all_payments.where(created_at: last_week.beginning_of_week..last_week.end_of_week)
    when "this_month"
      all_payments = all_payments.where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month)
    when "custom"
      if @start_date.present?
        start_time = safe_parse_date(@start_date)&.beginning_of_day
        all_payments = all_payments.where("payments.created_at >= ?", start_time) if start_time
      end

      if @end_date.present?
        end_time = safe_parse_date(@end_date)&.end_of_day
        all_payments = all_payments.where("payments.created_at <= ?", end_time) if end_time
      end
    end

    @payment_method_options = Payment.distinct.order(:payment_method).pluck(:payment_method)
    @total_count = all_payments.count
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
        customer_name = @payment.customer&.name || "Customer"
        customer_balance = @payment.customer&.balance.to_f
        payment_notice = if customer_balance <= 0
          "Payment created and SMS sent to #{customer_name}. Customer balance cleared."
        else
          "Payment created and SMS sent to #{customer_name}. Dues owed: KES #{@payment.customer&.balance}."
        end

        format.html { redirect_to payments_path, notice: payment_notice, status: :see_other }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:customer_id, :amount, :payment_method, :notes)
  end

  def safe_parse_date(value)
    Time.zone.parse(value)
  rescue ArgumentError, TypeError
    nil
  end
end
