class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :project, null: false, foreign_key: true
      t.string :status, null: false, default: "draft"
      t.string :number
      t.date :period_start
      t.date :period_end
      t.date :due_on
      t.datetime :issued_at
      t.datetime :paid_at
      t.string :sender_name
      t.text :sender_address
      t.string :sender_abn
      t.string :sender_email
      t.text :payment_instructions
      t.string :client_name
      t.text :client_address
      t.decimal :gst_rate, precision: 5, scale: 2, null: false, default: 10.0
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :tax_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0

      t.timestamps
    end

    add_index :invoices, :number, unique: true
  end
end
