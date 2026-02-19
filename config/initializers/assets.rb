# Be sure to restart your server when you modify this file.

# Propshaft (Rails 8) does not use config.assets.version, just extend its load paths.
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")
