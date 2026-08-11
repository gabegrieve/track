class CreateBusinessSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :business_settings do |t|
      t.string :business_name
      t.text :business_address
      t.string :abn
      t.string :email
      t.text :payment_instructions
      t.decimal :gst_rate, precision: 5, scale: 2, null: false, default: 10.0

      t.timestamps
    end
  end
end
