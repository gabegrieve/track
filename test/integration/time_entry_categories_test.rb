require "test_helper"

class TimeEntryCategoriesTest < ActionDispatch::IntegrationTest
  setup do
    @project = Project.create!(name: "Website", client_name: "Acme", hourly_rate_cents: 15_000)
    @budget = @project.service_budgets.create!(name: "Web design", budget_hours: 12)
    started_at = Time.zone.parse("2026-08-10 09:00")
    @entry = TimeEntry.create!(project: @project, description: "Homepage concepts", started_at:, ended_at: started_at + 1.hour, hourly_rate_cents: @project.hourly_rate_cents)
  end

  test "saves a category selected on an uninvoiced time entry" do
    patch time_entry_path(@entry), params: {
      time_entry: {
        description: @entry.description,
        project_id: @project.id,
        service_budget_id: @budget.id,
        started_at: @entry.started_at,
        ended_at: @entry.ended_at
      }
    }

    assert_redirected_to root_path
    assert_equal @budget, @entry.reload.service_budget
  end
end
