module Maziwaflow
  class NotificationTemplates
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
        name = customer&.name || "Customer"

        "Hello #{name}, 🥛 #{sale.liters}L delivered. " \
        "Amount: KES #{sale.total_amount}. " \
        "Balance: KES #{customer&.balance}. Thank you!"
      end

      def payment_template(payment)
        customer = payment.customer
        name = customer&.name || "Customer"

        "Confirmed: KES #{payment.amount} received. " \
        "New Balance: KES #{customer&.balance}. Thank you!"
      end
    end
  end
end
