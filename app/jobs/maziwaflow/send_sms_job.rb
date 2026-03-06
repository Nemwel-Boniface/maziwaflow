module Maziwaflow
  class SendSmsJob < ApplicationJob
    queue_as :default

    # Standard retry logic for network stability
    retry_on StandardError, wait: 5.seconds, attempts: 3

    def perform(notification_id:)
      notification = SmsNotification.find(notification_id)
      service = AtGatewayService.new

      result = service.send_sms(
        to: notification.phone_number,
        message: notification.message
      )

      if result.success?
        notification.update!(
          status: "sent",
          provider_message_id: result.provider_id,
          sent_at: Time.current
        )
      else
        notification.update!(
          status: "failed",
          error: result.error
        )

        # Re-raise error to trigger ActiveJob's retry mechanism
        raise "SMS send failed: #{result.error}"
      end

      result
    end
  end
end
