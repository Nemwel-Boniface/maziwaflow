module Maziwaflow
  class NotificationTemplates
    MAX_SMS_LENGTH = 150
    SIGN_OFF = "Friends at Maziwa flow"
    CUSTOM_BODY_MAX = 100
    PAYMENT_NUMBER = "0727475518"
    MILK_PRICE_PER_LITRE = 70

    class << self
      # Public: Builds a string message based on event type
      # event - :sale_created, :payment_received, :customer_created, :customer_deactivated
      # resource - The Sale or Payment object
      def build(event:, resource:)
        case event.to_sym
        when :sale_created
          sale_template(resource)
        when :payment_received
          payment_template(resource)
        when :customer_created
          customer_created_template(resource)
        when :customer_deactivated
          customer_deactivated_template(resource)
        else
          raise ArgumentError, "Unknown SMS event: #{event}"
        end
      end

      def build_custom(customer:, body:)
        name = first_name(customer&.name, fallback: "Customer")
        custom_message(name: name, body: body)
      end

      def max_custom_body_length_for_name(full_name)
        name = first_name(full_name, fallback: "Customer")
        [ custom_body_limit_for(name), CUSTOM_BODY_MAX ].min
      end

      def custom_body_input_limit
        CUSTOM_BODY_MAX
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

      def customer_created_template(customer)
        name = first_name(customer&.name, fallback: "Customer")

        compose_message(
          "Hi #{name}, welcome to Maziwa flow. Milk is KES #{MILK_PRICE_PER_LITRE}/L. " \
          "Pay via #{PAYMENT_NUMBER}. Glad to serve you."
        )
      end

      def customer_deactivated_template(customer)
        name = first_name(customer&.name, fallback: "Customer")

        compose_message(
          "Hi #{name}, thank you for being our customer. We appreciate your trust and hope to serve you again soon."
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

      def custom_message(name:, body:)
        clean_body = body.to_s.squish
        max_body_length = custom_body_limit_for(name)

        return "Hi #{name}, #{SIGN_OFF}" if max_body_length <= 0

        "Hi #{name}, #{clean_body[0...max_body_length].rstrip} #{SIGN_OFF}"
      end

      def custom_body_limit_for(name)
        greeting = "Hi #{name}, "
        separator = " "

        MAX_SMS_LENGTH - greeting.length - separator.length - SIGN_OFF.length
      end
    end
  end
end
