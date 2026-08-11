class CreateInvoiceBudgetSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_budget_summaries do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :service_budget, null: false, foreign_key: true
      t.string :name, null: false
      t.string :cadence, null: false
      t.date :period_start
      t.integer :budget_minutes, null: false
      t.integer :used_minutes, null: false

      t.timestamps
    end

    add_index :invoice_budget_summaries, [:invoice_id, :service_budget_id, :period_start], unique: true, name: "index_invoice_budget_summaries_on_snapshot"
  end
end
