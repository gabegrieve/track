class CreateInvoiceLines < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_lines do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :time_entry, null: false, foreign_key: true
      t.date :entry_date, null: false
      t.string :description, null: false
      t.integer :duration_minutes, null: false
      t.integer :hourly_rate_cents, null: false
      t.integer :amount_cents, null: false

      t.timestamps
    end
  end
end
