module Maziwaflow
  class NotificationTemplates
    MAX_SMS_LENGTH = 150
    SIGN_OFF = "Friends at Maziwa flow"

    class << self
      # Public: Builds a string message based on event type
      # event - :sale_created, :payment_received
      # resource - The Sale or Payment object
      def build(event:, resource:)
        case event.to_sym
        when :sale_created
          sale_template(resource)
        when :payment_received
          payment_template(resource)
        else
          raise ArgumentError, "Unknown SMS event: #{event}"
        end
      end

      private

      def sale_template(sale)
        customer = sale.customer
        name = first_name(customer&.name, fallback: "Customer")

        limit_message(
          "Hello #{name}, #{sale.liters}L delivered. " \
          "Amount: KES #{sale.total_amount}. " \
          "Balance: KES #{customer&.balance}. #{SIGN_OFF}"
        )
      end

      def payment_template(payment)
        customer = payment.customer
        name = first_name(customer&.name, fallback: "Customer")
        sender_name = first_name(payment.user&.name, fallback: "Maziwa")

        limit_message(
          "Hello #{name}, KES #{payment.amount} received by #{sender_name}. " \
          "New Balance: KES #{customer&.balance}. #{SIGN_OFF}"
        )
      end

      def first_name(full_name, fallback:)
        extracted_name = full_name.to_s.strip.split(/\s+/).first
        extracted_name.present? ? extracted_name.capitalize : fallback
      end

      def limit_message(message)
        message.to_s.strip[0...MAX_SMS_LENGTH]
      end
    end
  end
end
