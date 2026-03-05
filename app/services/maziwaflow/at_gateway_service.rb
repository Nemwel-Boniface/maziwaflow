require "AfricasTalking"

module Maziwaflow
  class AtGatewayService
    # Use a Struct for a clean, consistent response object
    Result = Struct.new(:success?, :provider_id, :error, keyword_init: true)

    def initialize
      # Senior move: Read from our centralized config initializer
      @username  = MAZIWAFLOW_SMS_CONFIG[:username]
      @api_key   = MAZIWAFLOW_SMS_CONFIG[:api_key]
      @sender_id = MAZIWAFLOW_SMS_CONFIG[:sender_id]

      at = AfricasTalking::Initialize.new(@username, @api_key)
      @sms = at.sms
    end

    def send_sms(to:, message:)
      # 1. Check if SMS is globally disabled in our config
      unless MAZIWAFLOW_SMS_CONFIG[:sms_enabled]
        return Result.new(success?: false, provider_id: nil, error: "SMS_DISABLED_IN_CONFIG")
      end

      formatted_phone = normalize_phone(to)

      options = {
        "to" => formatted_phone,
        "message" => message
      }

      # Sender ID is ignored by Africa's Talking in sandbox mode
      options["from"] = @sender_id if @sender_id.present? && !MAZIWAFLOW_SMS_CONFIG[:use_sandbox]

      # 2. Execute Send
      response = @sms.send(options)

      # 3. Parse Response
      # AT returns a hash. We dig for the messageId of the first recipient.
      recipient_data = response.dig("SMSMessageData", "Recipients", 0)

      if recipient_data && [ "Success", "Sent" ].include?(recipient_data["status"])
        Result.new(success?: true, provider_id: recipient_data["messageId"], error: nil)
      else
        error_msg = recipient_data&.fetch("status", "Unknown AT Error")
        Result.new(success?: false, provider_id: nil, error: error_msg)
      end

    rescue => e
      Rails.logger.error("[AtGatewayService] Critical Failure: #{e.class} - #{e.message}")
      Result.new(success?: false, provider_id: nil, error: e.message)
    end

    private

    def normalize_phone(phone)
      number = phone.to_s.gsub(/\D/, "")

      if number.start_with?("0") && number.length == 10
        "+254#{number[1..]}"
      elsif number.length == 9
        "+254#{number}"
      elsif number.start_with?("254")
        "+#{number}"
      else
        number.start_with?("+") ? number : "+#{number}"
      end
    end
  end
end
