class CreateTimeEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :time_entries do |t|
      t.references :project, null: false, foreign_key: true
      t.string :description, null: false
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :duration_minutes
      t.integer :hourly_rate_cents, null: false
      t.string :billing_status, null: false, default: "uninvoiced"

      t.index :billing_status

      t.timestamps
    end
  end
end
