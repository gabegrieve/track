class Invoice < ApplicationRecord
  belongs_to :project
  has_many :invoice_lines, dependent: :destroy
  has_many :time_entries, through: :invoice_lines

  enum :status, { draft: "draft", issued: "issued", paid: "paid", voided: "voided" }, default: :draft

  validates :period_start, :period_end, :due_on, presence: true
  validates :gst_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :period_is_ordered

  def self.build_draft!(project:, period_start:, period_end:, due_on:)
    entries = project.time_entries.completed.uninvoiced.where(started_at: period_start.beginning_of_day..period_end.end_of_day).order(:started_at)
    raise ActiveRecord::RecordInvalid, "There are no uninvoiced entries in that period" if entries.empty?

    transaction do
      invoice = create!(project:, period_start:, period_end:, due_on:, gst_rate: BusinessSetting.current.gst_rate)
      entries.each do |entry|
        invoice.invoice_lines.create!(
          time_entry: entry,
          entry_date: entry.started_at.to_date,
          description: entry.description,
          duration_minutes: entry.duration_minutes,
          hourly_rate_cents: entry.hourly_rate_cents,
          amount_cents: (entry.duration_minutes * entry.hourly_rate_cents / 60.0).round
        )
      end
      invoice.recalculate_totals!
      invoice
    end
  end

  def issue!
    transaction do
      lock!
      raise "Only draft invoices can be issued" unless draft?
      raise "Add at least one time entry before issuing" unless invoice_lines.exists?
      raise "One or more entries have already been invoiced" unless time_entries.uninvoiced.count == invoice_lines.count

      setting = BusinessSetting.current
      raise "Complete business settings before issuing an invoice" unless setting.ready_for_invoicing?

      assign_party_snapshots(setting)
      self.number = self.class.next_number
      self.issued_at = Time.current
      self.status = :issued
      recalculate_totals!
      save!
      time_entries.update_all(billing_status: "pending", updated_at: Time.current)
    end
  end

  def mark_paid!
    transaction do
      lock!
      raise "Only issued invoices can be marked paid" unless issued?

      update!(status: :paid, paid_at: Time.current)
      time_entries.update_all(billing_status: "paid", updated_at: Time.current)
    end
  end

  def void!
    transaction do
      lock!
      raise "Only issued invoices can be voided" unless issued?

      update!(status: :voided)
      time_entries.update_all(billing_status: "uninvoiced", updated_at: Time.current)
    end
  end

  def recalculate_totals!
    self.subtotal_cents = invoice_lines.sum(:amount_cents)
    self.tax_cents = (subtotal_cents * gst_rate.to_d / 100).round
    self.total_cents = subtotal_cents + tax_cents
    save! if persisted?
  end

  def self.next_number
    format("INV-%04d", where.not(number: nil).count + 1)
  end

  private

  def period_is_ordered
    return if period_start.blank? || period_end.blank? || period_end >= period_start

    errors.add(:period_end, "must be on or after the start date")
  end

  def assign_party_snapshots(setting)
    self.sender_name = setting.business_name
    self.sender_address = setting.business_address
    self.sender_abn = setting.abn
    self.sender_email = setting.email
    self.payment_instructions = setting.payment_instructions
    self.client_name = project.client_name
    self.client_address = project.client_address
    self.gst_rate = setting.gst_rate
  end
end
