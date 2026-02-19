# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

puts "Cleaning up roles..."
Role.destroy_all

puts "Creating default roles..."
[ :admin, :staff ].each do |role_name|
  Role.find_or_create_by!(name: role_name)
end

puts "Seeding the first Milkman (Admin)..."
admin_email = "admin@maziwaflow.com"
admin_password = "password123" # Change this immediately after login!

milkman = User.find_or_create_by!(email: admin_email) do |user|
  user.name = "The Milkman"
  user.password = admin_password
  user.password_confirmation = admin_password
end

# Assign the admin role using Rolify
milkman.add_role(:admin) unless milkman.has_role?(:admin)

puts "-------------------------------------------------------"
puts "Success! Login with:"
puts "Email: #{admin_email}"
puts "Password: #{admin_password}"
puts "-------------------------------------------------------"
