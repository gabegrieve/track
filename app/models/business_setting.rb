class BusinessSetting < ApplicationRecord
  validates :gst_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def self.current
    first_or_create!(gst_rate: 10)
  end

  def ready_for_invoicing?
    business_name.present? && business_address.present? && email.present? && payment_instructions.present?
  end
end
