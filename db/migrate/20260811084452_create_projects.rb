class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :client_name, null: false
      t.text :client_address
      t.integer :hourly_rate_cents, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
