class InvoiceLine < ApplicationRecord
  belongs_to :invoice
  belongs_to :time_entry

  validates :entry_date, :description, :duration_minutes, :hourly_rate_cents, :amount_cents, presence: true
end
