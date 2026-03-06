# Centralized configuration for MaziwaFlow SMS Infrastructure
# This reads from ENV variables for easier deployment across different environments.

MAZIWAFLOW_SMS_CONFIG = {
  username: ENV.fetch("AFRICASTALKING_USERNAME", nil),
  api_key: ENV.fetch("AFRICASTALKING_API_KEY", nil),
  sender_id: ENV.fetch("AFRICASTALKING_SENDER_ID", nil),

  # Cast strings to Boolean for safer logic in services
  use_sandbox: ActiveModel::Type::Boolean.new.cast(
    ENV.fetch("AFRICASTALKING_USE_SANDBOX", "true")
  ),

  sms_enabled: ActiveModel::Type::Boolean.new.cast(
    ENV.fetch("SMS_ENABLED", "true")
  ),

  default_phone_country: ENV.fetch("DEFAULT_PHONE_COUNTRY", "KE")
}.freeze
