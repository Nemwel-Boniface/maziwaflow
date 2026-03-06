module Maziwaflow
  class TriggerNotificationJob < ApplicationJob
    queue_as :default

    def perform(record_class:, record_id:, event:)
      record = record_class.constantize.find_by(id: record_id)
      return unless record

      # 1. Generate message using templates
      message = NotificationTemplates.build(event: event, resource: record)

      customer = notification_customer_for(record)
      return if customer&.phone_number.blank?

      # 2. Create Audit Record (Immediate visibility in UI)
      notification = SmsNotification.create!(
        notifiable: record,
        event: event.to_s,
        phone_number: customer.phone_number,
        message: message,
        status: "pending"
      )

      # 3. Hand off to the Worker for actual delivery
      Maziwaflow::SendSmsJob.perform_later(
        notification_id: notification.id
      )

      # 4. Update status to reflect it has entered the queue
      notification.update!(
        status: "queued"
      )

      Rails.logger.info("[TriggerNotificationJob] Enqueued SMS for #{record_class}##{record_id}")

      notification
    end

    private

    def notification_customer_for(record)
      return record if record.is_a?(Customer)

      record.respond_to?(:customer) ? record.customer : nil
    end
  end
end
