require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  setup do
    @project = Project.create!(name: "Website", client_name: "Acme", client_address: "1 Client Street", hourly_rate_cents: 15_000)
    started_at = 3.days.ago
    @entry = TimeEntry.create!(project: @project, description: "Design work", started_at:, ended_at: started_at + 1.hour, duration_minutes: 60, hourly_rate_cents: 15_000)
    BusinessSetting.create!(business_name: "Studio", business_address: "1 Studio Street", abn: "12 345 678 901", email: "hello@example.com", payment_instructions: "BSB 000-000 · Account 123456", gst_rate: 10)
  end

  test "issues and pays the time entries in a draft" do
    invoice = Invoice.build_draft!(project: @project, period_start: 1.week.ago.to_date, period_end: Date.current, due_on: 14.days.from_now.to_date)

    assert invoice.draft?
    assert_equal 15_000, invoice.subtotal_cents
    assert_equal 1_500, invoice.tax_cents

    invoice.issue!
    assert invoice.issued?
    assert_equal "pending", @entry.reload.billing_status

    invoice.mark_paid!
    assert invoice.paid?
    assert_equal "paid", @entry.reload.billing_status
  end

  test "voiding an issued invoice restores entries to uninvoiced" do
    invoice = Invoice.build_draft!(project: @project, period_start: 1.week.ago.to_date, period_end: Date.current, due_on: 14.days.from_now.to_date)
    invoice.issue!

    invoice.void!

    assert invoice.voided?
    assert_equal "uninvoiced", @entry.reload.billing_status
  end
end
