class AddServiceBudgetToTimeEntries < ActiveRecord::Migration[8.0]
  def change
    add_reference :time_entries, :service_budget, foreign_key: true
  end
end
