class CustomNotificationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @customers = active_customers
  end

  def create
    @customers = active_customers
    @audience = params[:audience].to_s
    @body = params[:body].to_s.squish

    recipients = selected_recipients

    if recipients.empty?
      flash.now[:alert] = "Select at least one active customer with a phone number."
      return render :new, status: :unprocessable_entity
    end

    if @body.blank?
      flash.now[:alert] = "Message body cannot be blank."
      return render :new, status: :unprocessable_entity
    end

    allowed_body_length = recipients.map do |customer|
      Maziwaflow::NotificationTemplates.max_custom_body_length_for_name(customer.name)
    end.min

    if @body.length > allowed_body_length
      flash.now[:alert] = "Message body is too long for selected recipients. Max allowed is #{allowed_body_length} characters."
      return render :new, status: :unprocessable_entity
    end

    queued_count = 0

    recipients.find_each do |customer|
      message = Maziwaflow::NotificationTemplates.build_custom(customer: customer, body: @body)

      notification = SmsNotification.create!(
        notifiable: customer,
        event: "custom_message",
        phone_number: customer.phone_number,
        message: message,
        status: "pending"
      )

      Maziwaflow::SendSmsJob.perform_later(notification_id: notification.id)
      notification.update!(status: "queued")
      queued_count += 1
    end

    redirect_to new_custom_notification_path, notice: "Custom SMS queued for #{queued_count} customer(s)."
  end

  private

  def active_customers
    Customer.active.where.not(phone_number: [ nil, "" ]).ordered
  end

  def selected_recipients
    if @audience == "selected"
      selected_ids = Array(params[:customer_ids]).reject(&:blank?)
      active_customers.where(id: selected_ids)
    else
      active_customers
    end
  end
end
