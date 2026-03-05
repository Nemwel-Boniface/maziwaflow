require "AfricasTalking"

module Maziwaflow
  class AtGatewayService
    Result = Struct.new(:success?, :provider_id, :error, keyword_init: true)

    def initialize
      # Ensure these are strictly strings and not nil
      @username  = MAZIWAFLOW_SMS_CONFIG[:username].to_s
      @api_key   = MAZIWAFLOW_SMS_CONFIG[:api_key].to_s
      @sender_id = MAZIWAFLOW_SMS_CONFIG[:sender_id].to_s

      # The Gem sometimes chokes if these are empty strings
      raise "Missing AT Credentials" if @username.blank? || @api_key.blank?

      at = ::AfricasTalking::Initialize.new(@username, @api_key)
      @sms = at.sms
    end

    def send_sms(to:, message:)
      # Safety check from your config
      unless MAZIWAFLOW_SMS_CONFIG[:sms_enabled]
        return Result.new(success?: false, provider_id: nil, error: "SMS_DISABLED")
      end

      # 1. Clean the phone number (Live AT requires +254...)
      formatted_phone = normalize_phone(to)

      # 2. Build options
      options = {
        "to" => formatted_phone,
        "message" => message
      }

      # Only add 'from' if it's present and NOT in sandbox mode
      if @sender_id.present? && !MAZIWAFLOW_SMS_CONFIG[:use_sandbox]
        options["from"] = @sender_id
      end

      # 3. Send
      response = @sms.send(options)

      # 4. Parse response safely
      status_data = extract_status_data(response)

      if status_data && [ "Success", "Sent" ].include?(status_data["status"])
        Result.new(success?: true, provider_id: status_data["messageId"], error: nil)
      else
        Result.new(success?: false, provider_id: nil, error: status_data&.fetch("status", "Unknown API Error"))
      end

    rescue => e
      # This catches that 'TypeError' and reports it to the Job
      Rails.logger.error("[AtGatewayService] Error: #{e.message}")
      Result.new(success?: false, provider_id: nil, error: e.message)
    end

    private

    def extract_status_data(response)
      case response
      when Array
        entry = response.first
        return nil unless entry

        if entry.respond_to?(:status) && entry.respond_to?(:messageId)
          {
            "status" => entry.status,
            "messageId" => entry.messageId
          }
        elsif entry.is_a?(Hash)
          {
            "status" => entry["status"] || entry[:status],
            "messageId" => entry["messageId"] || entry[:messageId]
          }
        end
      when Hash
        response.dig("SMSMessageData", "Recipients")&.first ||
          response.dig(:SMSMessageData, :Recipients)&.first
      end
    end

    def normalize_phone(phone)
      # Ensure we have a string and remove non-digits
      number = phone.to_s.gsub(/\D/, "")

      if number.start_with?("0") && number.length == 10
        "+254#{number[1..]}"
      elsif number.length == 9
        "+254#{number}"
      elsif number.start_with?("254") && number.length == 12
        "+#{number}"
      else
        number.start_with?("+") ? number : "+#{number}"
      end
    end
  end
end
