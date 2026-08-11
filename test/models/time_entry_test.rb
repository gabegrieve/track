require "test_helper"

class TimeEntryTest < ActiveSupport::TestCase
  setup do
    @project = Project.create!(name: "Website", client_name: "Acme", hourly_rate_cents: 15_000)
  end

  test "allows only one running timer" do
    TimeEntry.create!(project: @project, description: "First task", started_at: Time.current, hourly_rate_cents: @project.hourly_rate_cents)
    second = TimeEntry.new(project: @project, description: "Second task", started_at: Time.current, hourly_rate_cents: @project.hourly_rate_cents)

    assert_not second.valid?
    assert_includes second.errors.full_messages, "Only one timer can run at a time"
  end

  test "prevents changes to invoiced entries" do
    entry = TimeEntry.create!(project: @project, description: "Finished task", started_at: 2.hours.ago, ended_at: 1.hour.ago, duration_minutes: 60, hourly_rate_cents: @project.hourly_rate_cents, billing_status: :pending)
    budget = @project.service_budgets.create!(name: "Web design", budget_hours: 12)

    entry.service_budget = budget
    assert_not entry.valid?
    assert_includes entry.errors.full_messages, "Invoiced entries are locked"
  end

  test "recalculates duration when start and stop times are corrected" do
    entry = TimeEntry.create!(project: @project, description: "Finished task", started_at: 3.hours.ago, ended_at: 2.hours.ago, duration_minutes: 60, hourly_rate_cents: @project.hourly_rate_cents)

    entry.update!(started_at: Time.zone.parse("2026-08-10 09:15"), ended_at: Time.zone.parse("2026-08-10 11:00"))

    assert_equal 105, entry.duration_minutes
  end

  test "requires the service budget to belong to the project" do
    other_project = Project.create!(name: "Brand", client_name: "Acme", hourly_rate_cents: 15_000)
    budget = other_project.service_budgets.create!(name: "Asset design", budget_hours: 6)
    entry = TimeEntry.new(project: @project, service_budget: budget, description: "Finished task", started_at: 3.hours.ago, ended_at: 2.hours.ago, hourly_rate_cents: @project.hourly_rate_cents)

    assert_not entry.valid?
    assert_includes entry.errors[:service_budget], "must belong to the selected project"
  end
end
