class RolifyCreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table(:roles, id: :uuid) do |t| # Added UUID to roles themselves for consistency
      t.string :name
      t.references :resource, polymorphic: true, type: :uuid # Ensure polymorphic is UUID

      t.timestamps
    end

    create_table(:admins_roles, id: false) do |t|
      t.references :admin, type: :uuid, index: true # Explicitly set UUID type
      t.references :role, type: :uuid, index: true  # Explicitly set UUID type
    end

    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:admins_roles, [ :admin_id, :role_id ])
  end
end
