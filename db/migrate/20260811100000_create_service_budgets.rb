class CreateServiceBudgets < ActiveRecord::Migration[8.0]
  def change
    create_table :service_budgets do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :budget_minutes, null: false
      t.string :cadence, null: false, default: "project"
      t.boolean :archived, null: false, default: false

      t.timestamps
    end

    add_index :service_budgets, [:project_id, :archived, :name]
  end
end
