module Maziwaflow
  class NotificationTemplates
    MAX_SMS_LENGTH = 150
    SIGN_OFF = "Friends at Maziwa flow"
    PAYMENT_NUMBER = "0727475518"

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
        amount = sale.total_amount
        balance = customer&.balance

        compose_message(
          "Hi #{name}, you bought #{sale.liters}L milk worth KES #{amount}. " \
          "Dues: KES #{balance}. Pay via #{PAYMENT_NUMBER}."
        )
      end

      def payment_template(payment)
        customer = payment.customer
        name = first_name(customer&.name, fallback: "Customer")
        sender_name = first_name(payment.user&.name, fallback: "Maziwa")
        balance = customer&.balance.to_f

        return compose_message(
          "Hi #{name}, payment of KES #{payment.amount} received by #{sender_name}. " \
          "Your balance is cleared. Thank you for trusting us. Karibu tena."
        ) if balance <= 0

        compose_message(
          "Hi #{name}, KES #{payment.amount} received by #{sender_name}. " \
          "Dues: KES #{customer&.balance}."
        )
      end

      def first_name(full_name, fallback:)
        extracted_name = full_name.to_s.strip.split(/\s+/).first
        extracted_name.present? ? extracted_name.capitalize : fallback
      end

      def compose_message(body)
        clean_body = body.to_s.squish
        separator = " "
        max_body_length = MAX_SMS_LENGTH - SIGN_OFF.length - separator.length

        return SIGN_OFF[0...MAX_SMS_LENGTH] if max_body_length <= 0

        "#{clean_body[0...max_body_length].rstrip}#{separator}#{SIGN_OFF}"
      end
    end
  end
end
