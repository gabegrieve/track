class Project < ApplicationRecord
  has_many :time_entries, dependent: :restrict_with_error
  has_many :invoices, dependent: :restrict_with_error

  validates :name, :client_name, presence: true
  validates :hourly_rate_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def hourly_rate
    hourly_rate_cents.to_d / 100
  end
end
