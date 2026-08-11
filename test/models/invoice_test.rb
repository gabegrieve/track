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

  test "calculates project and monthly budgets across invoice months" do
    project = Project.create!(name: "Brand", client_name: "Acme", hourly_rate_cents: 15_000)
    project_budget = project.service_budgets.create!(name: "Web design", budget_hours: 12, cadence: :project)
    monthly_budget = project.service_budgets.create!(name: "Asset design", budget_hours: 6, cadence: :monthly)
    create_entry(project, project_budget, "2026-08-02 09:00", 120)
    create_entry(project, monthly_budget, "2026-08-26 09:00", 90)
    create_entry(project, monthly_budget, "2026-09-03 09:00", 180)

    invoice = Invoice.build_draft!(project:, period_start: Date.new(2026, 8, 25), period_end: Date.new(2026, 9, 5), due_on: Date.new(2026, 9, 19))
    summaries = invoice.budget_summaries

    project_summary = summaries.find { |summary| summary.service_budget == project_budget }
    august_summary = summaries.find { |summary| summary.service_budget == monthly_budget && summary.period_start == Date.new(2026, 8, 1) }
    september_summary = summaries.find { |summary| summary.service_budget == monthly_budget && summary.period_start == Date.new(2026, 9, 1) }

    assert_equal 120, project_summary.used_minutes
    assert_equal 90, august_summary.used_minutes
    assert_equal 180, september_summary.used_minutes
  end

  test "freezes budget utilisation when issued" do
    budget = @project.service_budgets.create!(name: "Web design", budget_hours: 12)
    @entry.update!(service_budget: budget)
    invoice = Invoice.build_draft!(project: @project, period_start: 1.week.ago.to_date, period_end: Date.current, due_on: 14.days.from_now.to_date)

    assert_equal 60, invoice.budget_summaries.first.used_minutes
    invoice.issue!
    budget.update!(budget_hours: 20)

    summary = invoice.reload.budget_summaries.first
    assert_equal 720, summary.budget_minutes
    assert_equal 60, summary.used_minutes
    assert InvoicePdf.new(invoice).render.start_with?("%PDF")
  end

  private

  def create_entry(project, budget, started_at, duration_minutes)
    started_at = Time.zone.parse(started_at)
    TimeEntry.create!(project:, service_budget: budget, description: "Design work", started_at:, ended_at: started_at + duration_minutes.minutes, hourly_rate_cents: project.hourly_rate_cents)
  end
end
